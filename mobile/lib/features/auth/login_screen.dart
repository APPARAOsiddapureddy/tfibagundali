import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/army_data.dart';
import '../../widgets/tfi_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController(text: '9876543291');
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      setState(() => _error = 'Enter valid 10-digit number');
      return;
    }
    final phone = '+91$digits';
    try {
      await context.read<AuthProvider>().sendOtp(phone);
      if (mounted) context.push('/otp', extra: phone);
    } catch (e) {
      setState(() => _error = e.toString());
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(gradient: TfiTokens.gradFire, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text('T', style: TfiTokens.display(22, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Text('TFI BAGUNDALI', style: TfiTokens.display(18, color: TfiTokens.textHi)),
                ],
              ),
              const SizedBox(height: 32),
              RichText(
                text: TextSpan(
                  style: TfiTokens.display(44, color: Colors.white, height: 1),
                  children: [
                    const TextSpan(text: 'Welcome,\n'),
                    TextSpan(text: 'Fan!', style: TextStyle(color: TfiTokens.fire)),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('మీ ఫ్యాన్ జర్నీ ఇక్కడ start అవుతుంది', style: TfiTokens.telugu(16, color: TfiTokens.textMid)),
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
                        style: TfiTokens.body(17, color: TfiTokens.textHi, w: FontWeight.w600),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '98XXX XXXXX'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: TfiTokens.body(12, color: TfiTokens.red))],
              const SizedBox(height: 28),
              PrimaryButton(label: 'Send OTP', icon: '📩', onPressed: _send),
              const SizedBox(height: 14),
              Text(
                '🔒 Login with OTP. No password needed.\nBy continuing you agree to our Terms & Privacy.',
                textAlign: TextAlign.center,
                style: TfiTokens.body(12, color: TfiTokens.textLo),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 90,
                child: Stack(
                  children: [
                    for (var i = 0; i < 6; i++)
                      Positioned(
                        left: MediaQuery.sizeOf(context).width * (0.1 + i * 0.12),
                        bottom: i.isEven ? 25 : 5,
                        child: Transform.rotate(
                          angle: (i - 2.5) * 0.07,
                          child: HeroAvatar(armyKey: ArmyData.keys[i], size: 44),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Text('8 ARMIES · 1 MISSION · YOURS', textAlign: TextAlign.center, style: TfiTokens.body(10, color: TfiTokens.textFaint, w: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
