import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../core/api/api_client.dart';
// import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
// import '../../core/utils/format_utils.dart';
import '../../widgets/poster_wall.dart';

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

    // Backend bypassed — navigate directly to OTP page
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _loading = false);
      context.push('/otp', extra: phone);
    }

    // --- Backend service (commented out for now) ---
    // try {
    //   await context.read<AuthProvider>().sendOtp(phone);
    //   if (mounted) context.push('/otp', extra: phone);
    // } on ApiException catch (e) {
    //   setState(() => _error = userFacingError(e));
    // } catch (e) {
    //   setState(() => _error = userFacingError(e));
    // } finally {
    //   if (mounted) setState(() => _loading = false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070D),
      body: Stack(
        children: [
          // ── Poster wall background ──
          const PosterWall(tint: 0.62),

          // ── Content ──
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Top brand bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        // Logo icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment(-0.8, -0.6),
                              end: Alignment(0.8, 0.8),
                              colors: [Color(0xFFFFB52E), Color(0xFFE5484D), Color(0xFF8B5CF6)],
                              stops: [0.0, 0.7, 1.0],
                            ),
                            boxShadow: [BoxShadow(color: TfiTokens.goldGlow.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('TFI Bagundali', style: TfiTokens.display(14, color: Colors.white)),
                        const Spacer(),
                        // FREE FOREVER badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: TfiTokens.green.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: TfiTokens.green.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF6FE3A0),
                                  boxShadow: [BoxShadow(color: const Color(0xFF6FE3A0), blurRadius: 8)],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text('FREE FOREVER', style: TfiTokens.body(10, color: const Color(0xFF6FE3A0), w: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Frosted card ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xB814162A), Color(0xEB0A0C18)],
                            ),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 60, offset: const Offset(0, 30)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Eyebrow
                              Text('● WELCOME FAN', style: TfiTokens.body(11, color: TfiTokens.gold, w: FontWeight.w700)),
                              const SizedBox(height: 6),

                              // Heading
                              Text('Login to the\nshow.', style: TfiTokens.display(34, color: Colors.white, height: 1)),
                              const SizedBox(height: 10),

                              // Subtitle
                              Text(
                                'Latest TFI updates, trivia, polls & wallpapers.',
                                style: TfiTokens.body(12.5, color: TfiTokens.textLo),
                              ),
                              const SizedBox(height: 22),

                              // Phone label
                              Text('PHONE NUMBER', style: TfiTokens.body(10.5, color: TfiTokens.textLo, w: FontWeight.w700)),
                              const SizedBox(height: 8),

                              // Phone input row
                              Row(
                                children: [
                                  // Country code box
                                  Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: TfiTokens.line),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Text('+91', style: TfiTokens.mono(14, color: Colors.white)),
                                        const SizedBox(width: 4),
                                        Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Number input
                                  Expanded(
                                    child: Container(
                                      height: 56,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: TfiTokens.gold, width: 1.5),
                                        boxShadow: [BoxShadow(color: TfiTokens.goldGlow.withValues(alpha: 0.12), blurRadius: 0, spreadRadius: 4)],
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: _phone,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                                        style: TfiTokens.mono(19, color: Colors.white, w: FontWeight.w600),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '98765 43210',
                                          hintStyle: TfiTokens.mono(19, color: Colors.white.withValues(alpha: 0.25), w: FontWeight.w600),
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onSubmitted: (_) => _loading ? null : _send(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (_error != null) ...[
                                const SizedBox(height: 8),
                                Text(_error!, style: TfiTokens.body(12, color: TfiTokens.red)),
                              ],

                              const SizedBox(height: 16),

                              // Send OTP button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: TfiTokens.gradGold,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [BoxShadow(color: TfiTokens.gold.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6))],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _loading ? null : _send,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _loading ? 'Sending...' : 'Send OTP',
                                            style: TfiTokens.body(16, color: Colors.white, w: FontWeight.w800),
                                          ),
                                          if (!_loading) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // No password note
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: TfiTokens.green.withValues(alpha: 0.16),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.star, color: Color(0xFF6FE3A0), size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TfiTokens.body(11.5, color: TfiTokens.textMid),
                                        children: [
                                          TextSpan(text: 'No password. ', style: TfiTokens.body(11.5, color: Colors.white, w: FontWeight.w800)),
                                          const TextSpan(text: "One quick OTP and you're in."),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Terms & Privacy
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TfiTokens.body(11, color: Colors.white.withValues(alpha: 0.4)),
                            children: [
                              const TextSpan(text: 'By continuing you agree to our '),
                              TextSpan(text: 'Terms', style: TfiTokens.body(11, color: Colors.white).copyWith(decoration: TextDecoration.underline)),
                              const TextSpan(text: ' & '),
                              TextSpan(text: 'Privacy', style: TfiTokens.body(11, color: Colors.white).copyWith(decoration: TextDecoration.underline)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
