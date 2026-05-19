import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/format_utils.dart';
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

  String get _code => _controllers.map((c) => c.text).join();

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

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButtonCircle(onTap: () => context.go('/login')),
            const SizedBox(height: 24),
            Text('VERIFY OTP', style: TfiTokens.display(36, color: TfiTokens.textHi)),
            Text('Sent to ${widget.phone}', style: TfiTokens.body(13, color: TfiTokens.textLo)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Container(
                  width: 46,
                  height: 54,
                  margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: TfiTokens.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TfiTokens.lineStrong),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controllers[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TfiTokens.display(24, color: TfiTokens.fire),
                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                      if (_code.length == 6) _verify();
                    },
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Center(child: Text(_error!, style: TfiTokens.body(12, color: TfiTokens.red))),
            ],
            const SizedBox(height: 28),
            PrimaryButton(label: _loading ? 'Verifying...' : 'Verify OTP', onPressed: _loading ? null : _verify),
            const SizedBox(height: 8),
            Center(child: Text('Dev OTP: 123456', style: TfiTokens.body(11, color: TfiTokens.textFaint))),
          ],
        ),
      ),
    );
  }
}
