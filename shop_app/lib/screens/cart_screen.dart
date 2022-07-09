import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text('Total', style: TextStyle(fontSize: 20)),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cartProvider.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartProvider),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.itemCount,
              itemBuilder: (ctx, i) {
                return CartItem(
                  cartProvider.items.values.toList()[i].id,
                  cartProvider.items.values.toList()[i].price,
                  cartProvider.items.values.toList()[i].quantity,
                  cartProvider.items.values.toList()[i].title,
                  cartProvider.items.keys.elementAt(i),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton(this.cartProvider);

  final CartProvider cartProvider;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  void _processOrder() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<OrdersProvider>(context, listen: false).addOrder(
      widget.cartProvider.items.values.toList(),
      widget.cartProvider.totalAmount,
    );
    setState(() {
      _isLoading = false;
    });
    widget.cartProvider.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (_isLoading || widget.cartProvider.itemCount == 0)
          ? null
          : _processOrder,
      textColor: Theme.of(context).primaryColor,
    );
  }
}
