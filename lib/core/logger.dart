// core/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void i(String message) => _logger.i(message);
  static void d(String message) => _logger.d(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error]) => _logger.e(message, error: error);
  
  static void success(String message) {
    _logger.i('✅ $message');
  }
}
