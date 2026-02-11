import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class AuthModal extends StatefulWidget {
  final double amount;
  final String payeeName;

  const AuthModal({
    super.key,
    required this.amount,
    required this.payeeName,
  });

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _status = 'Authenticate to confirm payment';

  @override
  void initState() {
    super.initState();
    // Auto-trigger auth when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (!mounted) return;

    setState(() {
      _isAuthenticating = true;
      _status = 'Scanning...';
    });

    bool authenticated = false;
    try {
      final canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuth) {
        // Simulate success for demo devices without biometrics
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
           setState(() => _status = 'Demo Authentication (Simulated)');
        }
        await Future.delayed(const Duration(milliseconds: 800));
        authenticated = true;
      } else {
        authenticated = await _auth.authenticate(
          localizedReason: 'Authenticate to pay ${Formatters.formatCurrency(widget.amount)}',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
      }
    } catch (e) {
      // Fallback for demo if error occurs
      if (mounted) {
        setState(() => _status = 'Demo Authentication (Fallback)');
      }
      await Future.delayed(const Duration(seconds: 1));
      authenticated = true;
    }

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _status = 'Authentication Cancelled');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.screenPadding,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fingerprint, size: 64, color: AppColors.primary),
          AppSpacing.verticalMD,
          Text(
            'Confirm Payment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.verticalSM,
          Text(
            'Paying ${widget.payeeName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            Formatters.formatCurrency(widget.amount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.verticalLG,
          Text(
            _status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          AppSpacing.verticalLG,
          if (!_isAuthenticating)
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                AppSpacing.horizontalMD,
                Expanded(
                  child: PrimaryButton(
                    label: 'Retry',
                    onPressed: _authenticate,
                  ),
                ),
              ],
            )
          else
            const CircularProgressIndicator(),
          AppSpacing.verticalMD,
        ],
      ),
    );
  }
}
