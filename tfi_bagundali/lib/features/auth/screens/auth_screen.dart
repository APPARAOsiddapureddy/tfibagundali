import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();
  bool _otpSent = false;
  String _sentTo = '';

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final raw = _phone.text.trim().replaceAll(RegExp(r'\s+'), '');
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Valid mobile number ivvandi', style: AppTheme.bodyMedium)),
      );
      return;
    }
    final phone = digits.length > 10 && digits.startsWith('91') ? digits.substring(2) : digits;
    final apiPhone = phone.length == 10 ? '91$phone' : digits;
    await ref.read(authProvider.notifier).sendOtp(apiPhone);
    if (!mounted) return;
    final err = ref.read(authProvider).error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err, style: AppTheme.bodyMedium)),
      );
      return;
    }
    setState(() {
      _otpSent = true;
      _sentTo = phone;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _otpFocus.requestFocus());
  }

  Future<void> _verify() async {
    final code = _otp.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('6 digit OTP enter cheyyandi', style: AppTheme.bodyMedium)),
      );
      return;
    }
    final apiPhone = _sentTo.length == 10 ? '91$_sentTo' : _sentTo;
    final ok = await ref.read(authProvider.notifier).verifyOtp(apiPhone, code);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(authProvider).error ?? 'Verify failed', style: AppTheme.bodyMedium)),
      );
      return;
    }
    final user = ref.read(authProvider).user;
    if (user?.isNewUser == true) {
      context.go('/onboard');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loading = auth.isLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.red.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'TFI BAGUNDALI',
                    textAlign: TextAlign.center,
                    style: AppTheme.headingLarge.copyWith(
                      fontSize: 34,
                      color: AppColors.red,
                      shadows: [
                        Shadow(blurRadius: 18, color: AppColors.red.withValues(alpha: 0.55)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.s8),
                  DefaultTextStyle(
                    style: AppTheme.telugu.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                    child: const Text('తెలుగు సినిమా కోసమే పుట్టిన App'),
                  ),
                  const SizedBox(height: AppTheme.s24),
                  if (!_otpSent) ...[
                    Text('Mobile Number', style: AppTheme.bodyLarge.copyWith(color: AppColors.textMuted2)),
                    const SizedBox(height: AppTheme.s8),
                    TextField(
                      controller: _phone,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        prefixText: '+91 ',
                        hintText: '98765 43210',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: AppTheme.s16),
                    _PrimaryButton(
                      loading: loading,
                      label: 'OTP Send Cheyyi →',
                      onPressed: loading ? null : _sendOtp,
                    ),
                    const SizedBox(height: AppTheme.s12),
                    Text(
                      'Dev mode: use 123456 as OTP',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(color: AppColors.textMuted2),
                    ),
                  ] else ...[
                    Text('OTP — $_sentTo', style: AppTheme.bodyLarge.copyWith(color: AppColors.textMuted2)),
                    const SizedBox(height: AppTheme.s8),
                    TextField(
                      controller: _otp,
                      focusNode: _otpFocus,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '123456',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: AppTheme.s16),
                    _PrimaryButton(
                      loading: loading,
                      label: 'Verify & Enter →',
                      onPressed: loading ? null : _verify,
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                _otpSent = false;
                                _otp.clear();
                              });
                            },
                      child: Text('← Change number', style: AppTheme.bodyMedium.copyWith(color: AppColors.textMuted2)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          disabledBackgroundColor: AppColors.bg4,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rButton)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: AppTheme.headingSmall.copyWith(color: Colors.white, fontSize: 22),
              ),
      ),
    );
  }
}
