import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../home_screen.dart';

// Theme Colors
const Color bgColor = Color(0xFF0A0E1A);
const Color cardColor = Color(0xFF151B2E);
const Color inputColor = Color(0xFF1E2642);
const Color neonGreen = Color(0xFF00FF94);
const Color neonBlue = Color(0xFF38BDF8);
const Color neonPurple = Color(0xFFA855F7);
const Color neonRed = Color(0xFFEF4444);

enum AuthMode {
  normal,      // Normal auth flow (check if lock enabled)
  setupPin,    // Force setup PIN mode
  changePin,   // Change existing PIN
}

class AuthScreen extends StatefulWidget {
  final AuthMode mode;
  
  const AuthScreen({
    super.key, 
    this.mode = AuthMode.normal,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = true;
  bool _canUseBiometrics = false;
  bool _isSettingPin = false;
  bool _isConfirmingPin = false;
  bool _hasPin = false;
  bool _appLockEnabled = false;
  
  String _enteredPin = '';
  String _firstPin = '';
  String _errorMessage = '';
  
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeAuth();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    // Check if app lock is enabled
    final prefs = await SharedPreferences.getInstance();
    _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    
    // Check if this is setup/change mode from settings
    if (widget.mode == AuthMode.setupPin || widget.mode == AuthMode.changePin) {
      // Force setup mode
      _isSettingPin = true;
      
      // Check biometric availability
      await _checkBiometrics();
      
      // Check existing PIN
      final storedPin = await _secureStorage.read(key: 'app_pin');
      _hasPin = storedPin != null && storedPin.isNotEmpty;
      
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Normal mode - check if lock is enabled
    if (!_appLockEnabled) {
      // App lock not enabled, go directly to home
      _navigateToHome();
      return;
    }

    // Check biometric availability
    await _checkBiometrics();

    // Check if PIN is set
    final storedPin = await _secureStorage.read(key: 'app_pin');
    _hasPin = storedPin != null && storedPin.isNotEmpty;

    setState(() {
      _isLoading = false;
    });

    // Auto-trigger biometric if available
    if (_canUseBiometrics && _hasPin) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      _canUseBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      _canUseBiometrics = _canUseBiometrics && isDeviceSupported;
      
      if (_canUseBiometrics) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        _canUseBiometrics = availableBiometrics.isNotEmpty;
      }
    } catch (e) {
      _canUseBiometrics = false;
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Autentikasi untuk membuka OSINT Stalker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        _navigateToHome();
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Biometric error: ${e.message}';
      });
    }
  }

  Future<void> _verifyPin() async {
    final storedPin = await _secureStorage.read(key: 'app_pin');
    
    if (_enteredPin == storedPin) {
      _navigateToHome();
    } else {
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = 'PIN salah! Coba lagi.';
        _enteredPin = '';
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _errorMessage = '';
          });
        }
      });
    }
  }

  Future<void> _setPin() async {
    if (_enteredPin.length != 4) return;
    
    if (!_isConfirmingPin) {
      // First entry
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _isConfirmingPin = true;
      });
    } else {
      // Confirm entry
      if (_enteredPin == _firstPin) {
        await _secureStorage.write(key: 'app_pin', value: _enteredPin);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('app_lock_enabled', true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.black),
                  SizedBox(width: 10),
                  Text('PIN berhasil diatur!', style: TextStyle(color: Colors.black)),
                ],
              ),
              backgroundColor: neonGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          
          // If from settings, go back. If normal flow, go to home.
          if (widget.mode == AuthMode.setupPin || widget.mode == AuthMode.changePin) {
            Navigator.pop(context, true); // Return true to indicate success
          } else {
            _navigateToHome();
          }
        }
      } else {
        _shakeController.forward(from: 0);
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage = 'PIN tidak cocok! Ulangi dari awal.';
          _enteredPin = '';
          _firstPin = '';
          _isConfirmingPin = false;
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _errorMessage = '';
            });
          }
        });
      }
    }
  }

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    if (key == 'delete') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
      }
    } else if (key == 'bio') {
      _authenticateWithBiometrics();
    } else {
      if (_enteredPin.length < 4) {
        setState(() {
          _enteredPin += key;
        });
        
        if (_enteredPin.length == 4) {
          if (_isSettingPin) {
            _setPin();
          } else {
            _verifyPin();
          }
        }
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: neonGreen),
        ),
      );
    }

    // If no PIN set, show setup screen
    if (!_hasPin) {
      _isSettingPin = true;
    }
    
    // Determine title and subtitle based on mode
    String title;
    String subtitle;
    if (widget.mode == AuthMode.changePin) {
      title = _isConfirmingPin ? 'Konfirmasi PIN Baru' : 'Buat PIN Baru';
      subtitle = _isConfirmingPin 
          ? 'Masukkan PIN yang sama untuk konfirmasi' 
          : 'Masukkan PIN 4 digit baru';
    } else if (_isSettingPin) {
      title = _isConfirmingPin ? 'Konfirmasi PIN' : 'Buat PIN Baru';
      subtitle = _isConfirmingPin 
          ? 'Masukkan PIN yang sama untuk konfirmasi' 
          : 'Buat PIN 4 digit untuk mengamankan aplikasi';
    } else {
      title = 'Masukkan PIN';
      subtitle = 'Masukkan PIN 4 digit Anda';
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: (widget.mode == AuthMode.setupPin || widget.mode == AuthMode.changePin)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context, false),
              ),
              title: Text(
                widget.mode == AuthMode.changePin ? 'Ubah PIN' : 'Setup PIN',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Lock icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonGreen.withOpacity(0.1),
                  border: Border.all(color: neonGreen.withOpacity(0.3)),
                ),
                child: Icon(
                  _isSettingPin ? Icons.lock_open : Icons.lock,
                  color: neonGreen,
                  size: 50,
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 30),
              
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // PIN dots
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeController.value < 0.5
                      ? _shakeController.value * 20 - 10
                      : (1 - _shakeController.value) * 20 - 10;
                  return Transform.translate(
                    offset: Offset(offset * (1 - _shakeController.value), 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? neonGreen : Colors.transparent,
                        border: Border.all(
                          color: isFilled ? neonGreen : Colors.white30,
                          width: 2,
                        ),
                        boxShadow: isFilled
                            ? [BoxShadow(color: neonGreen.withOpacity(0.5), blurRadius: 10)]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Error message
              AnimatedOpacity(
                opacity: _errorMessage.isNotEmpty ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: neonRed, fontSize: 14),
                ),
              ),
              
              const Spacer(),
              
              // Number pad
              _buildNumberPad(),
              
              const SizedBox(height: 20),
              
              // Skip button (only for initial setup from splash, not from settings)
              if (_isSettingPin && !_hasPin && widget.mode == AuthMode.normal)
                TextButton(
                  onPressed: () {
                    _navigateToHome();
                  },
                  child: const Text(
                    'Lewati untuk sekarang',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((e) => _buildKeyButton(e)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((e) => _buildKeyButton(e)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((e) => _buildKeyButton(e)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Biometric button
            _canUseBiometrics && !_isSettingPin
                ? _buildKeyButton('bio', icon: Icons.fingerprint)
                : const SizedBox(width: 70),
            _buildKeyButton('0'),
            _buildKeyButton('delete', icon: Icons.backspace_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyButton(String value, {IconData? icon}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPressed(value),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value == 'bio' ? neonBlue.withOpacity(0.2) : cardColor,
            border: Border.all(
              color: value == 'bio' ? neonBlue.withOpacity(0.5) : Colors.white10,
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: value == 'bio' ? neonBlue : Colors.white70,
                    size: value == 'bio' ? 32 : 24,
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Utility class for managing app lock
class AppLockManager {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  /// Check if app lock is enabled
  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('app_lock_enabled') ?? false;
  }
  
  /// Enable app lock
  static Future<void> enableAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', true);
  }
  
  /// Disable app lock
  static Future<void> disableAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', false);
    await _secureStorage.delete(key: 'app_pin');
  }
  
  /// Check if PIN is set
  static Future<bool> hasPinSet() async {
    final pin = await _secureStorage.read(key: 'app_pin');
    return pin != null && pin.isNotEmpty;
  }
  
  /// Change PIN
  static Future<void> changePin(String newPin) async {
    await _secureStorage.write(key: 'app_pin', value: newPin);
  }
  
  /// Verify PIN
  static Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: 'app_pin');
    return pin == storedPin;
  }
  
  /// Check if biometrics available
  static Future<bool> canUseBiometrics() async {
    final localAuth = LocalAuthentication();
    try {
      final canCheck = await localAuth.canCheckBiometrics;
      final isSupported = await localAuth.isDeviceSupported();
      if (canCheck && isSupported) {
        final available = await localAuth.getAvailableBiometrics();
        return available.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
