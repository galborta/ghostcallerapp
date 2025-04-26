import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/app/config/env_config.dart';

void main() {
  group('EnvConfig Tests', () {
    test('initialize loads environment variables', () async {
      await EnvConfig.initialize();
      
      expect(EnvConfig.appName, isNotEmpty);
      expect(EnvConfig.appEnv, isNotEmpty);
      expect(EnvConfig.supabaseUrl, isNotEmpty);
      expect(EnvConfig.supabaseAnonKey, isNotEmpty);
      
      // Print values for verification
      EnvConfig.printConfig();
    });
    
    test('environment flags work correctly', () async {
      await EnvConfig.initialize();
      
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isProduction, isFalse);
    });
  });
} 