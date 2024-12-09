import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:roso_jogja_mobile/shared/config/route_generator.dart";

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (_) {
          CookieRequest request = CookieRequest();
          return request;
        },
        child: MaterialApp(
          title: 'Roso Jogja Mobile',
          theme: ThemeData(
            // Orange and white color scheme
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.orange,
              backgroundColor: Colors.white,
              cardColor: Colors.white,
              errorColor: Colors.red,
              brightness: Brightness.light,
            ),
            // Default font family
            fontFamily: 'Roboto',
            // Default text theme
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/login',
          onGenerateRoute: RouteGenerator.generateRoute,
        ));
  }
}
