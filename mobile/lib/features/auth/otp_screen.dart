import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/poster_wall.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  // Resend countdown
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  String get _formattedPhone {
    final p = widget.phone.replaceAll('+91', '').trim();
    if (p.length == 10) {
      return '+91 ${p.substring(0, 5)} ${p.substring(5)}';
    }
    return widget.phone;
  }

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Enter 6-digit OTP');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = await context.read<AuthProvider>().verifyOtp(widget.phone, _code);
      if (!mounted) return;
      context.go(auth.needsOnboarding ? '/onboarding/hero' : '/home');
    } on ApiException catch (e) {
      setState(() => _error = userFacingError(e));
    } catch (e) {
      setState(() => _error = userFacingError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    try {
      await context.read<AuthProvider>().sendOtp(widget.phone);
      _startResendTimer();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070D),
      body: Stack(
        children: [
          // ── Poster wall background ──
          const PosterWall(tint: 0.7),

          // ── Content ──
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Top bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '● Step 2 of 2 · Verify',
                          style: TfiTokens.body(12, color: Colors.white.withValues(alpha: 0.6), w: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Ticket stub card ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        // The ticket
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [TfiTokens.ticketBg, TfiTokens.ticketBgEnd],
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 60, offset: const Offset(0, 30)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Header strip ──
                                  _buildHeader(),

                                  // ── Dashed divider ──
                                  _dashedDivider(),

                                  // ── Phone row ──
                                  _buildPhoneRow(),

                                  // ── OTP section ──
                                  const SizedBox(height: 14),
                                  Text(
                                    'ENTER 6-DIGIT CODE',
                                    style: TfiTokens.body(9, color: TfiTokens.ticketDark.withValues(alpha: 0.65), w: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 12),

                                  // ── OTP boxes ──
                                  _buildOtpBoxes(),

                                  if (_error != null) ...[
                                    const SizedBox(height: 8),
                                    Center(child: Text(_error!, style: TfiTokens.body(11, color: TfiTokens.red, w: FontWeight.w600))),
                                  ],

                                  const SizedBox(height: 16),

                                  // ── Resend row ──
                                  _buildResendRow(),

                                  const SizedBox(height: 14),

                                  // ── Verify button ──
                                  _buildVerifyButton(),

                                  const SizedBox(height: 18),

                                  // ── Barcode ──
                                  _dashedDivider(),
                                  const SizedBox(height: 14),
                                  _buildBarcode(),
                                ],
                              ),
                            ),

                            // ── Perforation notches ──
                            Positioned(
                              left: -10,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF06070D),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -10,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF06070D),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Auto-detect note
                        Text(
                          'Auto-detecting OTP from SMS…',
                          style: TfiTokens.body(11, color: Colors.white.withValues(alpha: 0.5)),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '● TFI BAGUNDALI',
                  style: TfiTokens.body(9.5, color: TfiTokens.ticketDark.withValues(alpha: 0.65), w: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('FAN TICKET', style: TfiTokens.display(24, color: TfiTokens.ticketDark, height: 1.05)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'HALL',
                style: TfiTokens.body(9, color: TfiTokens.ticketDark.withValues(alpha: 0.6), w: FontWeight.w700),
              ),
              Text('A1', style: TfiTokens.mono(24, color: TfiTokens.ticketDark, w: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SENT TO',
                  style: TfiTokens.body(9, color: TfiTokens.ticketDark.withValues(alpha: 0.6), w: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(_formattedPhone, style: TfiTokens.mono(15, color: TfiTokens.ticketDark)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TfiTokens.ticketAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Edit', style: TfiTokens.body(11, color: TfiTokens.ticketAccent, w: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      children: List.generate(6, (i) {
        final hasValue = _controllers[i].text.isNotEmpty;
        final isCurrent = !hasValue && (i == 0 || _controllers[i > 0 ? i - 1 : 0].text.isNotEmpty);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: hasValue ? Colors.white : TfiTokens.ticketDark.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? TfiTokens.ticketAccent : TfiTokens.ticketDark.withValues(alpha: 0.18),
                  width: isCurrent ? 2 : 1.5,
                ),
                boxShadow: isCurrent
                    ? [BoxShadow(color: TfiTokens.ticketAccent.withValues(alpha: 0.15), blurRadius: 0, spreadRadius: 4)]
                    : [BoxShadow(color: TfiTokens.ticketDark.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1))],
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TfiTokens.display(26, color: TfiTokens.ticketDark),
                cursorColor: TfiTokens.ticketAccent,
                decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) {
                    _focusNodes[i + 1].requestFocus();
                  }
                  if (v.isEmpty && i > 0) {
                    _focusNodes[i - 1].requestFocus();
                  }
                  setState(() {}); // rebuild to update box styling
                  if (_code.length == 6) _verify();
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendRow() {
    final canResend = _resendSeconds <= 0;
    final timeStr = '0:${_resendSeconds.toString().padLeft(2, '0')}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: canResend ? _resendOtp : null,
          child: Text(
            "Didn't get it?",
            style: TfiTokens.body(11.5, color: TfiTokens.ticketDark.withValues(alpha: canResend ? 0.8 : 0.6)),
          ),
        ),
        if (!canResend)
          RichText(
            text: TextSpan(
              style: TfiTokens.body(11.5, color: TfiTokens.ticketDark, w: FontWeight.w700),
              children: [
                const TextSpan(text: 'Resend in '),
                TextSpan(text: timeStr, style: TfiTokens.mono(12, color: TfiTokens.ticketAccent, w: FontWeight.w700)),
              ],
            ),
          ),
        if (canResend)
          GestureDetector(
            onTap: _resendOtp,
            child: Text('Resend OTP', style: TfiTokens.body(11.5, color: TfiTokens.ticketAccent, w: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0F00), Color(0xFF2B1900)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: TfiTokens.ticketDark.withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _loading ? null : _verify,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: TfiTokens.goldWarm, size: 18),
                const SizedBox(width: 8),
                Text(
                  _loading ? 'Verifying...' : 'Verify & Enter',
                  style: TfiTokens.body(15, color: TfiTokens.goldWarm, w: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarcode() {
    const bars = [2, 3, 1, 4, 2, 3, 5, 2, 1, 3, 4, 2, 3, 1, 2, 5, 3, 2, 4, 1, 3, 2, 4, 2];
    return Row(
      children: [
        // Barcode lines
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars.map((w) {
            return Container(
              width: w.toDouble(),
              height: 26,
              margin: const EdgeInsets.only(right: 1.5),
              color: TfiTokens.ticketDark,
            );
          }).toList(),
        ),
        const Spacer(),
        Text('TFI · 6:00 AM', style: TfiTokens.mono(10, color: TfiTokens.ticketDark.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: 4,
              height: 1.5,
              color: TfiTokens.ticketDark.withValues(alpha: 0.35),
            );
          }),
        );
      },
    );
  }
}
