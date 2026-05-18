import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/tfi_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TfiScreen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0.3),
            radius: 1.1,
            colors: [Color(0xFF2A1318), Color(0xFF0D0512), Color(0xFF050208)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    transform: Matrix4.rotationZ(-0.1),
                    decoration: BoxDecoration(
                      gradient: TfiTokens.gradFire,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: TfiTokens.fireDeep.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 12))],
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text('T', style: TfiTokens.display(64, color: Colors.white)),
                        const Positioned(top: -8, right: -12, child: Text('🔥', style: TextStyle(fontSize: 28))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [Colors.white, TfiTokens.gold]).createShader(b),
                    child: Text('TFI', style: TfiTokens.display(52, color: Colors.white)),
                  ),
                  Text('BAGUNDALI', style: TfiTokens.display(36, color: TfiTokens.fire)),
                  const SizedBox(height: 26),
                  Text('మన సినిమా. మన ఆర్మీ. మన ప్రైడ్.', textAlign: TextAlign.center, style: TfiTokens.telugu(17, color: TfiTokens.textMid)),
                  const SizedBox(height: 6),
                  Text('MANA CINEMA · MANA ARMY · MANA PRIDE', style: TfiTokens.body(11, color: TfiTokens.textFaint, w: FontWeight.w700)),
                ],
              ),
            ),
            Positioned(
              left: 60,
              right: 60,
              bottom: 56,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: const LinearProgressIndicator(minHeight: 3, backgroundColor: Color(0x14FFFFFF), valueColor: AlwaysStoppedAnimation(TfiTokens.fire)),
                  ),
                  const SizedBox(height: 12),
                  Text('LOADING THE MASS...', style: TfiTokens.body(11, color: TfiTokens.textFaint, w: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
