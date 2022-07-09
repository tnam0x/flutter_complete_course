import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

const APP_KEY = 'AIzaSyDEHBb2sjqR3QoDJjOFF6FXLKpBnUtno64';
const SIGNUP_URL =
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=';
const SIGNIN_URL =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  Future<void> _authenticate(String email, String password, String url) async {
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final body = json.decode(response.body);
      if (body['error'] != null) throw HttpException(body['error']['message']);

      _token = body['idToken'];
      _userId = body['localId'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(body['expiresIn'])),
      );
      print('$_userId,${body['expiresIn']}');
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    final url = '$SIGNUP_URL$APP_KEY';
    return _authenticate(email, password, url);
  }

  Future<void> login(String email, String password) async {
    final url = '$SIGNIN_URL$APP_KEY';
    return _authenticate(email, password, url);
  }
}
