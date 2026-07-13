import 'package:flutter/material.dart';

import 'theme/aero_theme.dart';

class AeroColors {
  // Compatibility aliases for legacy screens. New code must use ColorScheme or
  // AeroSemanticColors through context.aero.
  static const navy = AeroPalette.darkCanvas;
  static const navyLight = AeroPalette.darkSurface;
  static const navyCard = AeroPalette.darkElevatedSurface;
  static const amber = AeroPalette.primary;
  static const amberBright = AeroPalette.skyBlue;
  static const amberLight = AeroPalette.lightBlueSurface;
  static const amberBorder = Color(0xFFBFDBFE);
  static const white = Colors.white;
  static const grey = Color(0xFF888888);
  static const greyLight = Color(0xFFB0B0B0);
  static const lightGrey = Color(0xFF555555);
  static const background = Color(0xFFF0F2F8);
  static const cardBorder = Color(0xFFE0E0E8);
  static const cardWhite = Color(0xFFFFFFFF);
  static const success = AeroPalette.success;
  static const successLight = Color(0xFFE1F5EE);
  static const danger = AeroPalette.danger;
  static const dangerLight = Color(0xFFFCEBEB);
  static const infoLight = Color(0xFFE6F1FB);
  static const infoText = AeroPalette.information;
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
        color: Colors.black.withValues(alpha: 0.06),
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
    border: Border.all(color: AeroColors.success.withValues(alpha: 0.3)),
  );
}
