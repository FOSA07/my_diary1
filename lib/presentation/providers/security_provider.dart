import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isLocked = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  String? _pin;
  DateTime? _lastUnlockTime;
  int _autoLockMinutes = 5;

  // Getters
  bool get isLocked => _isLocked;
  bool get biometricEnabled => _biometricEnabled;
  bool get pinEnabled => _pinEnabled;
  bool get hasPin => _pin != null;
  int get autoLockMinutes => _autoLockMinutes;

  // Initialize security settings
  Future<void> initialize() async {
    await _loadSettings();
    _checkAutoLock();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _pinEnabled = prefs.getBool('pin_enabled') ?? false;
    _pin = prefs.getString('user_pin');
    _autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;
    _isLocked = _biometricEnabled || _pinEnabled;
    
    final lastUnlockTimestamp = prefs.getInt('last_unlock_time');
    if (lastUnlockTimestamp != null) {
      _lastUnlockTime = DateTime.fromMillisecondsSinceEpoch(lastUnlockTimestamp);
    }
    
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', _biometricEnabled);
    await prefs.setBool('pin_enabled', _pinEnabled);
    await prefs.setInt('auto_lock_minutes', _autoLockMinutes);
    
    if (_pin != null) {
      await prefs.setString('user_pin', _pin!);
    } else {
      await prefs.remove('user_pin');
    }
    
    if (_lastUnlockTime != null) {
      await prefs.setInt('last_unlock_time', _lastUnlockTime!.millisecondsSinceEpoch);
    }
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Enable/disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;
      
      final authenticated = await authenticateWithBiometric();
      if (!authenticated) return false;
    }
    
    _biometricEnabled = enabled;
    if (!enabled && !_pinEnabled) {
      _isLocked = false;
    } else {
      _isLocked = true;
    }
    
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // Set PIN
  Future<bool> setPin(String pin) async {
    if (pin.length < 4) return false;
    
    _pin = pin;
    _pinEnabled = true;
    _isLocked = true;
    
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // Remove PIN
  Future<void> removePin() async {
    _pin = null;
    _pinEnabled = false;
    if (!_biometricEnabled) {
      _isLocked = false;
    }
    
    await _saveSettings();
    notifyListeners();
  }

  // Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your diary',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (authenticated) {
        _unlock();
      }
      
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  // Authenticate with PIN
  bool authenticateWithPin(String pin) {
    if (_pin == pin) {
      _unlock();
      return true;
    }
    return false;
  }

  // Unlock the app
  void _unlock() {
    _isLocked = false;
    _lastUnlockTime = DateTime.now();
    _saveSettings();
    notifyListeners();
  }

  // Lock the app
  void lock() {
    if (_biometricEnabled || _pinEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  // Check if app should auto-lock
  void _checkAutoLock() {
    if (_lastUnlockTime != null && (_biometricEnabled || _pinEnabled)) {
      final timeSinceUnlock = DateTime.now().difference(_lastUnlockTime!);
      if (timeSinceUnlock.inMinutes >= _autoLockMinutes) {
        _isLocked = true;
      }
    }
  }

  // Set auto-lock duration
  Future<void> setAutoLockMinutes(int minutes) async {
    _autoLockMinutes = minutes;
    await _saveSettings();
    notifyListeners();
  }

  // Check if app should be locked when resuming
  void checkLockOnResume() {
    _checkAutoLock();
    notifyListeners();
  }

  // Get security status summary
  String get securityStatus {
    if (!_biometricEnabled && !_pinEnabled) {
      return 'No security enabled';
    } else if (_biometricEnabled && _pinEnabled) {
      return 'Biometric + PIN enabled';
    } else if (_biometricEnabled) {
      return 'Biometric enabled';
    } else {
      return 'PIN enabled';
    }
  }

  // Check if any security is enabled
  bool get hasSecurityEnabled => _biometricEnabled || _pinEnabled;
}
