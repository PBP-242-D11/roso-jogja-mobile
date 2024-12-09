import 'package:flutter/material.dart';
import "package:pbp_django_auth/pbp_django_auth.dart";
import 'package:roso_jogja_mobile/features/auth/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final CookieRequest _cookieRequest;

  CookieRequest get cookieRequest => _cookieRequest; // Expose CookieRequest

  User? _user;
  bool get isLoggedIn => _cookieRequest.loggedIn;
  User? get user => _user;

  AuthProvider(this._cookieRequest);

  Future<void> init() async {
    try {
      await _cookieRequest.init();
      if (_cookieRequest.loggedIn) {
        _user = User.fromJson(_cookieRequest.getJsonData());
      }
    } catch (e) {
      _user = null;
    }
    notifyListeners();
  }

  Future<dynamic> login(String url, dynamic data) async {
    try {
      final response = await _cookieRequest.login(url, data);
      if (_cookieRequest.loggedIn) {
        _user = User.fromJson(_cookieRequest.getJsonData());
      } else {
        _user = null;
      }
      notifyListeners();
      return response;
    } catch (e) {
      _user = null;
      notifyListeners();
      return {'error': e.toString()};
    }
  }

  Future<dynamic> logout(String url) async {
    try {
      final response = await _cookieRequest.logout(url);
      if (!_cookieRequest.loggedIn) {
        _user = null;
      }
      notifyListeners();
      return response;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
