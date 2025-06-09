import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/app_constants.dart';
import '../providers/security_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isAuthenticating = false;
  String _enteredPin = '';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    // Try biometric authentication immediately if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricAuth();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricAuth() async {
    final securityProvider = context.read<SecurityProvider>();
    
    if (securityProvider.biometricEnabled && !_isAuthenticating) {
      setState(() {
        _isAuthenticating = true;
      });
      
      final success = await securityProvider.authenticateWithBiometric();
      
      setState(() {
        _isAuthenticating = false;
      });
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _onPinDigitPressed(String digit) {
    if (_enteredPin.length < 6) {
      setState(() {
        _enteredPin += digit;
      });
      
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onPinBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    final securityProvider = context.read<SecurityProvider>();
    
    if (securityProvider.authenticateWithPin(_enteredPin)) {
      Navigator.of(context).pop();
    } else {
      _shakeController.forward().then((_) {
        _shakeController.reset();
        setState(() {
          _enteredPin = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final securityProvider = context.watch<SecurityProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon and Title
              Container(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              Text(
                'My Diary',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppConstants.smallPadding),

              Text(
                'Enter your PIN to continue',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppConstants.largePadding * 2),

              // PIN Dots
              if (securityProvider.pinEnabled) ...[
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < _enteredPin.length
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.3),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // PIN Keypad
                _buildPinKeypad(colorScheme, theme),
              ],

              const SizedBox(height: AppConstants.largePadding),

              // Biometric Authentication Button
              if (securityProvider.biometricEnabled) ...[
                ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _tryBiometricAuth,
                  icon: _isAuthenticating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(_isAuthenticating ? 'Authenticating...' : 'Use Biometric'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.defaultPadding,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinKeypad(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      children: [
        // Numbers 1-3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1', colorScheme, theme),
            _buildKeypadButton('2', colorScheme, theme),
            _buildKeypadButton('3', colorScheme, theme),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Numbers 4-6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4', colorScheme, theme),
            _buildKeypadButton('5', colorScheme, theme),
            _buildKeypadButton('6', colorScheme, theme),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Numbers 7-9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7', colorScheme, theme),
            _buildKeypadButton('8', colorScheme, theme),
            _buildKeypadButton('9', colorScheme, theme),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // 0 and Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space
            _buildKeypadButton('0', colorScheme, theme),
            _buildKeypadButton('⌫', colorScheme, theme, isBackspace: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(
    String text,
    ColorScheme colorScheme,
    ThemeData theme, {
    bool isBackspace = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isBackspace) {
          _onPinBackspace();
        } else {
          _onPinDigitPressed(text);
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                )
              : Text(
                  text,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
