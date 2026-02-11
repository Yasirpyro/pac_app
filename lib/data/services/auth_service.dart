import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable && !isDeviceSupported) {
        // In demo mode, simulate success after a delay
        await Future.delayed(const Duration(milliseconds: 800));
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to confirm payment',
      );
    } on PlatformException {
      // Fallback: simulate authentication for demo
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }
  }

  Future<bool> canAuthenticate() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
}
