import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing (4px baseline rhythm)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Corner Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0; // Interactive buttons, inputs
  static const double radiusLg = 16.0; // Standard cards
  static const double radiusXl = 20.0; // Feature cards & modals
  static const double radiusPill = 999.0; // Chips, badges

  static const BorderRadius borderXs =
      BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl =
      BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderPill =
      BorderRadius.all(Radius.circular(radiusPill));

  // Elevations & Shadows
  static const List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowModal = [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  // Component Heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 38.0;
  static const double inputHeight = 50.0;
  static const double topBarHeight = 60.0;
  static const double bottomNavHeight = 72.0;
}
