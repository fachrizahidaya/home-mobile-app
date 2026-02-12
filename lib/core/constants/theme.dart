import 'package:flutter/material.dart';

class CustomTheme {
  EdgeInsets padding(type) {
    switch (type) {
      case 'card':
        return EdgeInsets.all(12.0);
      case 'warning-text':
        return EdgeInsets.only(top: 4, left: 8);
      case 'text-form':
        return EdgeInsets.symmetric(vertical: 12, horizontal: 16);
      case 'button':
        return EdgeInsets.symmetric(vertical: 16, horizontal: 24);

      default:
        return EdgeInsets.all(16.0);
    }
  }

  double vGap(size) {
    switch (size) {
      case 's':
        return 4.0;
      case 'm':
        return 8.0;
      case 'l':
        return 12.0;
      case 'xl':
        return 20.0;
      case '2xl':
        return 28.0;
      case '3xl':
        return 36.0;

      default:
        return 16.0;
    }
  }

  double hGap(size) {
    switch (size) {
      case 's':
        return 4.0;
      case 'm':
        return 8.0;
      case 'l':
        return 12.0;
      case 'xl':
        return 20.0;
      case '2xl':
        return 28.0;
      case '3xl':
        return 36.0;

      default:
        return 16.0;
    }
  }

  double fontSize(type) {
    switch (type) {
      case 's':
        return 10;
      case 'l':
        return 14;
      case 'xl':
        return 16;
      case '2xl':
        return 18;

      default:
        return 12;
    }
  }

  FontWeight fontWeight(type) {
    switch (type) {
      case 'thin':
        return FontWeight.w200;
      case 'semibold':
        return FontWeight.w600;
      case 'bold':
        return FontWeight.w800;

      default:
        return FontWeight.w400;
    }
  }

  BorderRadius borderRadius(type) {
    switch (type) {
      case 'child':
        return BorderRadius.circular(8.0);

      default:
        return BorderRadius.circular(12.0);
    }
  }
}
