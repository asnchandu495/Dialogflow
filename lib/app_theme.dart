import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  MyTheme._();

  static Color kWhite = const Color(0xffFFFFFF);
  static Color kPrimaryColorVariant = const Color(0xff686795);
  static Color kRedish = const Color(0xffDE1B54);
  static Color kAccentColorVariant = const Color(0xffF7A3A2);
  static Color kUnreadChatBG = const Color(0xffEE1D1D);
  static Color kBgColor = const Color(0xffE5E5E5);
  static Color kAppbarColor = const Color(0xffFFFFFF);
  static const  Color kBlueShade =  Color(0xFF26235D);
  static const Color kDarkGrey = Color(0xFF2A2A2A);
  static const Color kChatTimeColor = Color(0xFF5C5C5C);
  static final TextStyle kAppTitle = GoogleFonts.roboto(fontSize: 36);

  static const TextStyle heading2 = TextStyle(
    color: Color(0xff686795),
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static const TextStyle chatSenderName = TextStyle(
    color: MyTheme.kBlueShade,
    fontSize: 16,
    fontWeight: FontWeight.w700,

  );

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
  // background: #5C5C5C;
  static const TextStyle chatTime = TextStyle(
      color: MyTheme.kChatTimeColor,
      fontSize: 12,
      fontWeight: FontWeight.w400);

  static const TextStyle chatConversation = TextStyle(
      color: MyTheme.kChatTimeColor,
      fontSize: 14,
      fontWeight: FontWeight.w400);

  static const TextStyle bodyText1 = TextStyle(
      color: Color(0xffAEABC9),
      fontSize: 14,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w500);

  static const TextStyle bodyTextMessage =
      TextStyle(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w600);

  static const TextStyle bodyTextTime = TextStyle(
    color: Color(0xffAEABC9),
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );
}
