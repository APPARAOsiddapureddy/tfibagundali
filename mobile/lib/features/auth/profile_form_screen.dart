import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/poster_wall.dart';

/// Ticket-style profile form — collects Name, Age, Place, Gender.
/// Navigates to /home with the user's name on submit.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key, this.heroKey, this.heroName});
  final String? heroKey;
  final String? heroName;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  String? _selectedGender;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (_ageCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your age');
      return;
    }
    if (_placeCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your place');
      return;
    }

    // Navigate to home with the user's name
    context.go('/home', extra: {
      'userName': _nameCtrl.text.trim(),
      'heroKey': widget.heroKey,
      'heroName': widget.heroName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070D),
      body: Stack(
        children: [
          const PosterWall(tint: 0.72),

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
                        GestureDetector(
                          onTap: () => context.go('/onboarding/hero'),
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
                          '● Step 4 of 4 · Profile',
                          style: TfiTokens.body(12, color: Colors.white.withValues(alpha: 0.6), w: FontWeight.w600),
                        ),
                        const Spacer(),
                        // Progress dots
                        Row(
                          children: List.generate(4, (i) {
                            return Container(
                              width: 22,
                              height: 4,
                              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: TfiTokens.gold, // all 4 steps active
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Ticket card ──
                  Expanded(
                    flex: 8,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        children: [
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
                                    // ── Header ──
                                    _buildHeader(),
                                    _dashedDivider(),
                                    const SizedBox(height: 16),

                                    // ── Name field ──
                                    _buildLabel('YOUR NAME'),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _nameCtrl,
                                      hint: 'Enter your full name',
                                      icon: Icons.person_outline,
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Age field ──
                                    _buildLabel('AGE'),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _ageCtrl,
                                      hint: 'e.g. 22',
                                      icon: Icons.cake_outlined,
                                      keyboardType: TextInputType.number,
                                      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Place field ──
                                    _buildLabel('PLACE / CITY'),
                                    const SizedBox(height: 6),
                                    _buildTextField(
                                      controller: _placeCtrl,
                                      hint: 'e.g. Hyderabad',
                                      icon: Icons.location_on_outlined,
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Gender selection ──
                                    _buildLabel('GENDER'),
                                    const SizedBox(height: 6),
                                    _buildGenderRow(),
                                    const SizedBox(height: 16),

                                    // ── Favourite hero (read-only) ──
                                    if (widget.heroName != null) ...[
                                      _buildLabel('FAVOURITE HERO'),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: TfiTokens.gold.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: TfiTokens.gold.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, color: Color(0xFFB8860B), size: 18),
                                            const SizedBox(width: 10),
                                            Text(widget.heroName!, style: TfiTokens.body(15, color: TfiTokens.ticketDark, w: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    if (_error != null) ...[
                                      Center(child: Text(_error!, style: TfiTokens.body(11, color: TfiTokens.red, w: FontWeight.w600))),
                                      const SizedBox(height: 12),
                                    ],

                                    // ── Submit button ──
                                    _buildSubmitButton(),

                                    const SizedBox(height: 18),
                                    _dashedDivider(),
                                    const SizedBox(height: 14),

                                    // ── Barcode ──
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
                          Text(
                            'Your data stays on your device for now.',
                            style: TfiTokens.body(11, color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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
                Text('FAN PASS', style: TfiTokens.display(24, color: TfiTokens.ticketDark, height: 1.05)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SEAT',
                style: TfiTokens.body(9, color: TfiTokens.ticketDark.withValues(alpha: 0.6), w: FontWeight.w700),
              ),
              Text('VIP', style: TfiTokens.mono(24, color: TfiTokens.ticketDark, w: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TfiTokens.body(9.5, color: TfiTokens.ticketDark.withValues(alpha: 0.65), w: FontWeight.w700),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TfiTokens.ticketDark.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [BoxShadow(color: TfiTokens.ticketDark.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: TfiTokens.body(15, color: TfiTokens.ticketDark, w: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TfiTokens.body(15, color: TfiTokens.ticketDark.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: TfiTokens.ticketDark.withValues(alpha: 0.4), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        ),
      ),
    );
  }

  Widget _buildGenderRow() {
    const genders = ['Male', 'Female', 'Other'];
    return Row(
      children: genders.map((g) {
        final selected = _selectedGender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? TfiTokens.ticketDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? TfiTokens.ticketDark : TfiTokens.ticketDark.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                g,
                style: TfiTokens.body(13, color: selected ? TfiTokens.goldWarm : TfiTokens.ticketDark, w: FontWeight.w700),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
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
            onTap: _submit,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: TfiTokens.goldWarm, size: 18),
                const SizedBox(width: 8),
                Text('Enter the Show', style: TfiTokens.body(15, color: TfiTokens.goldWarm, w: FontWeight.w800)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: TfiTokens.goldWarm, size: 18),
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
        Text('TFI · FAN PASS', style: TfiTokens.mono(10, color: TfiTokens.ticketDark.withValues(alpha: 0.6))),
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
