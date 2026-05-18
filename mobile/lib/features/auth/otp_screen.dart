import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _error = 'Enter 6-digit OTP');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final isNew = await context.read<AuthProvider>().verifyOtp(widget.phone, code);
      if (!mounted) return;
      context.go(isNew ? '/onboard' : '/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F0820), TfiTokens.bg1, Color(0xFF060810)]),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButtonCircle(onTap: () => context.go('/login')),
                  const SizedBox(width: 12),
                  Text('STEP 2 OF 3', style: TfiTokens.body(12, color: TfiTokens.textLo, w: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 24),
              Text('VERIFY OTP', style: TfiTokens.display(38, color: TfiTokens.textHi)),
              const SizedBox(height: 12),
              Text('OTP మీ మొబైల్ కి పంపించాం', style: TfiTokens.telugu(15, color: TfiTokens.textMid)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: TfiTokens.body(13, color: TfiTokens.textLo),
                  children: [
                    const TextSpan(text: 'Sent to '),
                    TextSpan(text: widget.phone, style: TfiTokens.body(13, color: TfiTokens.textHi, w: FontWeight.w700)),
                    TextSpan(text: ' · ', style: TfiTokens.body(13, color: TfiTokens.textLo)),
                    const TextSpan(text: 'Edit', style: TextStyle(color: TfiTokens.fire, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: 48,
                    height: 58,
                    margin: EdgeInsets.only(right: i < 5 ? 10 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TfiTokens.lineStrong, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _controllers[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TfiTokens.display(26, color: TfiTokens.fire),
                      decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                      },
                    ),
                  );
                }),
              ),
              if (_error != null) ...[const SizedBox(height: 12), Center(child: Text(_error!, style: TfiTokens.body(12, color: TfiTokens.red)))],
              const SizedBox(height: 22),
              Center(child: Text('Resend OTP in 00:24', style: TfiTokens.body(13, color: TfiTokens.textLo))),
              const SizedBox(height: 32),
              PrimaryButton(label: _loading ? 'Verifying...' : 'Verify OTP', onPressed: _loading ? null : _verify),
              const SizedBox(height: 22),
              TfiCard(
                child: Row(
                  children: [
                    const Text('🛡️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('We auto-detect OTPs from SMS.\nNever share your OTP with anyone.', style: TfiTokens.body(12, color: TfiTokens.textMid)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text('Dev OTP: 123456', style: TfiTokens.body(11, color: TfiTokens.textFaint))),
            ],
          ),
        ),
      ),
    );
  }
}
