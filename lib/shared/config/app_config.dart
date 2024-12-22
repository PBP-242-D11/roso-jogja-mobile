import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String apiUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';
  static final bool isDebugMode = dotenv.env['DEBUG'] == 'true';
}
