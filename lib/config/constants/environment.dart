import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }

  static String urlBASE = dotenv.env['URL_BASE'] ?? 'No URL_BASE';
}
