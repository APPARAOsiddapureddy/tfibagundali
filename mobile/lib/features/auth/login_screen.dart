import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/tfi_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String? _validatePhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length < 10) return 'Enter 10-digit mobile number';
    if (digits.length > 10) return 'Use 10 digits only (without +91)';
    return null;
  }

  Future<void> _send() async {
    final err = _validatePhone(_phone.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    final phone = '+91$local';

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().sendOtp(phone);
      if (mounted) context.push('/otp', extra: phone);
    } on ApiException catch (e) {
      setState(() => _error = userFacingError(e));
    } catch (e) {
      setState(() => _error = userFacingError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0820), TfiTokens.bg1, Color(0xFF060810)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TFI BAGUNDALI', style: TfiTokens.display(18, color: TfiTokens.textHi)),
              const SizedBox(height: 32),
              Text('Welcome,\nFan!', style: TfiTokens.display(40, color: TfiTokens.fire)),
              const SizedBox(height: 8),
              Text('మీ TFI updates journey — phone OTP only', style: TfiTokens.telugu(15, color: TfiTokens.textMid)),
              const SizedBox(height: 28),
              Text('PHONE NUMBER', style: TfiTokens.body(12, color: TfiTokens.textLo, w: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TfiTokens.lineStrong),
                ),
                child: Row(
                  children: [
                    const Text('🇮🇳 ', style: TextStyle(fontSize: 18)),
                    Text('+91', style: TfiTokens.body(15, color: TfiTokens.textHi, w: FontWeight.w700)),
                    Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 10), color: TfiTokens.line),
                    Expanded(
                      child: TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        style: TfiTokens.body(17, color: TfiTokens.textHi, w: FontWeight.w600),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '10-digit number'),
                        onSubmitted: (_) => _loading ? null : _send(),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TfiTokens.body(12, color: TfiTokens.red)),
              ],
              const SizedBox(height: 28),
              PrimaryButton(label: _loading ? 'Sending...' : 'Send OTP', icon: '📩', onPressed: _loading ? null : _send),
            ],
          ),
        ),
      ),
    );
  }
}
