import 'package:flutter/widgets.dart';

class SizeConfig {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double blockSizeHorizontal(BuildContext context) {
    return screenWidth(context) / 100;
  }

  static double blockSizeVertical(BuildContext context) {
    return screenHeight(context) / 100;
  }

  static double safeBlockHorizontal(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double safeAreaHorizontal = mediaQueryData.padding.left + mediaQueryData.padding.right;
    return (screenWidth(context) - safeAreaHorizontal) / 100;
  }

  static double safeBlockVertical(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double safeAreaVertical = mediaQueryData.padding.top + mediaQueryData.padding.bottom;
    return (screenHeight(context) - safeAreaVertical) / 100;
  }
}
