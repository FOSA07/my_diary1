import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/app_constants.dart';
import '../providers/security_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Section
            SettingsSection(
              title: 'Security & Privacy',
              icon: Icons.security,
              children: [
                Consumer<SecurityProvider>(
                  builder: (context, securityProvider, child) {
                    return Column(
                      children: [
                        SettingsTile(
                          title: 'Biometric Authentication',
                          subtitle: securityProvider.biometricEnabled
                              ? 'Enabled'
                              : 'Disabled',
                          leading: const Icon(Icons.fingerprint),
                          trailing: Switch(
                            value: securityProvider.biometricEnabled,
                            onChanged: (value) async {
                              final success = await securityProvider.setBiometricEnabled(value);
                              if (!success && value) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Biometric authentication not available'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SettingsTile(
                          title: 'PIN Protection',
                          subtitle: securityProvider.pinEnabled
                              ? 'Enabled'
                              : 'Disabled',
                          leading: const Icon(Icons.pin),
                          trailing: Switch(
                            value: securityProvider.pinEnabled,
                            onChanged: (value) {
                              if (value) {
                                _showSetPinDialog();
                              } else {
                                securityProvider.removePin();
                              }
                            },
                          ),
                        ),
                        if (securityProvider.hasSecurityEnabled) ...[
                          SettingsTile(
                            title: 'Auto-lock',
                            subtitle: 'Lock after ${securityProvider.autoLockMinutes} minutes',
                            leading: const Icon(Icons.timer),
                            onTap: () => _showAutoLockDialog(),
                          ),
                          SettingsTile(
                            title: 'Security Status',
                            subtitle: securityProvider.securityStatus,
                            leading: const Icon(Icons.info_outline),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Appearance Section
            SettingsSection(
              title: 'Appearance',
              icon: Icons.palette,
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SettingsTile(
                      title: 'Theme',
                      subtitle: themeProvider.themeModeName,
                      leading: Icon(themeProvider.themeIcon),
                      onTap: () => _showThemeDialog(),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Data Section
            SettingsSection(
              title: 'Data & Storage',
              icon: Icons.storage,
              children: [
                SettingsTile(
                  title: 'Export Data',
                  subtitle: 'Export your diary entries',
                  leading: const Icon(Icons.download),
                  onTap: () => _showExportDialog(),
                ),
                SettingsTile(
                  title: 'Import Data',
                  subtitle: 'Import diary entries',
                  leading: const Icon(Icons.upload),
                  onTap: () => _showImportDialog(),
                ),
                SettingsTile(
                  title: 'Clear All Data',
                  subtitle: 'Delete all diary entries',
                  leading: const Icon(Icons.delete_forever),
                  textColor: colorScheme.error,
                  onTap: () => _showClearDataDialog(),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // About Section
            SettingsSection(
              title: 'About',
              icon: Icons.info,
              children: [
                SettingsTile(
                  title: 'Version',
                  subtitle: AppConstants.appVersion,
                  leading: const Icon(Icons.info_outline),
                ),
                SettingsTile(
                  title: 'Privacy Policy',
                  subtitle: 'View privacy policy',
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () => _showPrivacyPolicy(),
                ),
                SettingsTile(
                  title: 'Terms of Service',
                  subtitle: 'View terms of service',
                  leading: const Icon(Icons.description),
                  onTap: () => _showTermsOfService(),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),
          ],
        ),
      ),
    );
  }

  void _showSetPinDialog() {
    showDialog(
      context: context,
      builder: (context) => _SetPinDialog(),
    );
  }

  void _showAutoLockDialog() {
    final securityProvider = context.read<SecurityProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-lock Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1 minute'),
              leading: Radio<int>(
                value: 1,
                groupValue: securityProvider.autoLockMinutes,
                onChanged: (value) {
                  securityProvider.setAutoLockMinutes(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('5 minutes'),
              leading: Radio<int>(
                value: 5,
                groupValue: securityProvider.autoLockMinutes,
                onChanged: (value) {
                  securityProvider.setAutoLockMinutes(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('15 minutes'),
              leading: Radio<int>(
                value: 15,
                groupValue: securityProvider.autoLockMinutes,
                onChanged: (value) {
                  securityProvider.setAutoLockMinutes(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('30 minutes'),
              leading: Radio<int>(
                value: 30,
                groupValue: securityProvider.autoLockMinutes,
                onChanged: (value) {
                  securityProvider.setAutoLockMinutes(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.light_mode),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.dark_mode),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('System'),
              leading: const Icon(Icons.brightness_auto),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export functionality will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Import functionality will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your diary entries. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear data functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear data functionality will be available soon'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. All diary entries are stored locally on your device and are not transmitted to any external servers. We do not collect, store, or share any personal information.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to use it responsibly and in accordance with applicable laws. The app is provided as-is without warranties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SetPinDialog extends StatefulWidget {
  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            decoration: const InputDecoration(
              labelText: 'Enter PIN (4-6 digits)',
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
          ),
          TextField(
            controller: _confirmPinController,
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_pinController.text == _confirmPinController.text &&
                _pinController.text.length >= 4) {
              final success = await context.read<SecurityProvider>().setPin(_pinController.text);
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN set successfully')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PINs do not match or are too short')),
              );
            }
          },
          child: const Text('Set PIN'),
        ),
      ],
    );
  }
}
