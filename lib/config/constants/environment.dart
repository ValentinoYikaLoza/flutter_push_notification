import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }

  static String urlFMC = dotenv.env['URL_FMC'] ?? 'No URL_FMC';
}
