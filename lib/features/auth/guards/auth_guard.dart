import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/pages/login.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (!request.loggedIn) {
      return child;
    }

    return child;
  }
}
