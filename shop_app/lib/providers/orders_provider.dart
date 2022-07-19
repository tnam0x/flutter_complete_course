import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/Api.dart';
import 'package:shop_app/providers/cart_provider.dart';

class Order {
  final String id;
  final double amount;
  final List<Cart> products;
  final DateTime dateTime;

  Order({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class OrdersProvider with ChangeNotifier {
  String authToken;
  List<Order> _orders = [];

  OrdersProvider(this.authToken, this._orders);

  List<Order> get orders {
    return [..._orders];
  }

  int get itemCount => _orders.length;

  Future<void> fetchAndSetOrders() async {
    final url = '$DB_URL/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<Order> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) return;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        Order(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => Cart(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<Cart> carts, double total) async {
    final url = '$DB_URL/orders.json?auth=$authToken';
    final timestamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': carts
            .map((cart) => {
                  'id': cart.id,
                  'title': cart.title,
                  'quantity': cart.quantity,
                  'price': cart.price,
                })
            .toList()
      }),
    );

    _orders.insert(
      0,
      Order(
        id: json.decode(response.body)['name'],
        amount: total,
        products: carts,
        dateTime: timestamp,
      ),
    );
    notifyListeners();
  }
}
