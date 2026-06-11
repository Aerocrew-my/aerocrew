import 'package:flutter/material.dart';

class AeroColors {
  static const navy = Color(0xFF0A0E1A);
  static const navyLight = Color(0xFF141927);
  static const navyCard = Color(0xFF1C2333);
  static const amber = Color(0xFFBA7517);
  static const amberBright = Color(0xFFE8920A);
  static const amberLight = Color(0xFFFFF8EC);
  static const amberBorder = Color(0xFFFAEEDA);
  static const white = Colors.white;
  static const grey = Color(0xFF888888);
  static const greyLight = Color(0xFFB0B0B0);
  static const lightGrey = Color(0xFF555555);
  static const background = Color(0xFFF0F2F8);
  static const cardBorder = Color(0xFFE0E0E8);
  static const cardWhite = Color(0xFFFFFFFF);
  static const success = Color(0xFF1D9E75);
  static const successLight = Color(0xFFE1F5EE);
  static const danger = Color(0xFFA32D2D);
  static const dangerLight = Color(0xFFFCEBEB);
  static const infoLight = Color(0xFFE6F1FB);
  static const infoText = Color(0xFF185FA5);
  static const divider = Color(0xFF2A3347);
}

class AeroText {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AeroColors.white,
    letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AeroColors.white,
    letterSpacing: -0.3,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AeroColors.navy,
    letterSpacing: -0.2,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AeroColors.grey,
    letterSpacing: 1.2,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AeroColors.navy,
    height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AeroColors.grey,
    height: 1.4,
  );
}

class AeroDecoration {
  static BoxDecoration darkCard = BoxDecoration(
    color: AeroColors.navyCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AeroColors.divider, width: 0.5),
  );

  static BoxDecoration lightCard = BoxDecoration(
    color: AeroColors.cardWhite,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration amberCard = BoxDecoration(
    color: AeroColors.amberLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AeroColors.amberBorder),
  );

  static BoxDecoration successCard = BoxDecoration(
    color: AeroColors.successLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AeroColors.success.withOpacity(0.3)),
  );
}