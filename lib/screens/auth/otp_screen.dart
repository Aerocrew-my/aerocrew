import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/auth/product_selection_screen.dart';
import 'package:aerocrew/screens/operator/operator_profile_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  const OtpScreen({super.key, required this.phone, required this.role});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  bool isLoading = false;

void _verify() {
  setState(() => isLoading = true);
  Future.delayed(const Duration(seconds: 1), () {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.role == 'operator'
            ? const OperatorProfileScreen()
            : const ProductSelectionScreen(),
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AeroColors.navyCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AeroColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AeroColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_outline,
                            color: AeroColors.amber, size: 28),
                      ),
                      const SizedBox(height: 20),
                      const Text('Verify your number',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text(
                        'We sent a 6-digit code to\n${widget.phone}',
                        style: const TextStyle(
                            fontSize: 15,
                            color: AeroColors.grey,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AeroColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text('ENTER OTP CODE',
                              style: AeroText.label),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) {
                              return SizedBox(
                                width: 44,
                                height: 54,
                                child: TextField(
                                  controller: controllers[i],
                                  focusNode: focusNodes[i],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AeroColors.amber,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AeroColors.cardWhite,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AeroColors.amberBorder,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AeroColors.amberBorder,
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AeroColors.amber,
                                          width: 2),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val.isNotEmpty && i < 5) {
                                      focusNodes[i + 1].requestFocus();
                                    }
                                    if (val.isEmpty && i > 0) {
                                      focusNodes[i - 1].requestFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _verify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AeroColors.amber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2))
                                  : const Text('Verify & continue',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: RichText(
                              text: const TextSpan(
                                text: "Didn't receive the code? ",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AeroColors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Resend',
                                    style: TextStyle(
                                        color: AeroColors.amber,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AeroColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AeroColors.infoText
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline,
                                    color: AeroColors.infoText, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'For security, your number is verified before accessing AeroCrew.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AeroColors.infoText,
                                        height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}