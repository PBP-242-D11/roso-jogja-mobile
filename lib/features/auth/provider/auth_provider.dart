import 'package:flutter/material.dart';
import "package:pbp_django_auth/pbp_django_auth.dart";

class AuthProvider extends ChangeNotifier {
  final CookieRequest _cookieRequest;

  CookieRequest get cookieRequest => _cookieRequest; // Expose CookieRequest

  Map<String, dynamic>? _user;
  bool get isLoggedIn => _cookieRequest.loggedIn;
  Map<String, dynamic>? get user => _user;

  AuthProvider(this._cookieRequest);

  Future<void> init() async {
    await _cookieRequest.init();
    if (_cookieRequest.loggedIn) {
      _user = _cookieRequest.getJsonData();
    }
    notifyListeners();
  }

  Future<dynamic> login(String url, dynamic data) async {
    final response = await _cookieRequest.login(url, data);
    if (_cookieRequest.loggedIn) {
      _user = _cookieRequest.getJsonData();
    } else {
      _user = null;
    }
    notifyListeners();
    return response;
  }

  Future<dynamic> logout(String url) async {
    final response = await _cookieRequest.logout(url);
    if (!_cookieRequest.loggedIn) {
      _user = null;
    }
    notifyListeners();
    return response;
  }
}
