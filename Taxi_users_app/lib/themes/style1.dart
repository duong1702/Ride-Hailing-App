import 'package:flutter/material.dart';

TextStyle textStyle = const TextStyle(
  color: Color(0XFF000000),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle textStyleWhite = const TextStyle(
  color: Color(0XFFFFFFFF),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle textBoldBlack = const TextStyle(
  color: Color(0XFF000000),
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle textBoldWhite = const TextStyle(
  color: Color(0XFFFFFFFF),
  fontSize: 10.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle textBlackItalic = const TextStyle(
  color: Color(0XFF000000),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
  fontFamily: "OpenSans",
);

TextStyle textGrey = const TextStyle(
  color: Colors.grey,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle textGreyBold = const TextStyle(
  color: Colors.grey,
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle textStyleBlue = const TextStyle(
  color: primaryColor,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle textStyleActive = const TextStyle(
  color: Color(0xFFF44336),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle textStyleValidate = const TextStyle(
  color: Color(0xFFF44336),
  fontSize: 11.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
  fontFamily: "OpenSans",
);

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    // subtitle1: base.subtitle1.copyWith(
    //   fontFamily: 'GoogleSans',
    // ),
  );
}

TextStyle textGreen = const TextStyle(
  color: Color(0xFF00c497),
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

final ThemeData base = ThemeData.light();

ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ).copyWith(
    primary: primaryColor,
    secondary: const Color(0xFF13B9FD), // Thay cho accentColor
    surface: Colors.white,
    error: const Color(0xFFB00020),
  ),
  indicatorColor: Colors.white,
  splashColor: Colors.white24,
  splashFactory: InkRipple.splashFactory,
  hintColor: const Color(0xFF13B9FD),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: primaryColor),
  buttonTheme: const ButtonThemeData(
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: _buildTextTheme(base.textTheme),
  primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
);


///todo
Color textFieldColor = const Color.fromRGBO(168, 160, 149, 0.6);
const Color whiteColor = Color(0XFFFFFFFF);
const Color blackColor = Color(0XFF242A37);
const Color disabledColor = Color(0XFFF7F8F9);
const Color greyColor = Colors.grey;
Color greyColor2 = Colors.grey.withOpacity(0.3);
const Color activeColor = Color(0xFFF44336);
const Color redColor = Color(0xFFFF0000);
const Color buttonStop = Color(0xFFF44336);
const Color primaryColor = Color(0xFFFFD428);
const Color secondary = Color(0xFFFF8900);
const Color facebook = Color(0xFF4267b2);
const Color googlePlus = Color(0xFFdb4437);
const Color yellow = Colors.pinkAccent;
const Color green1 = Colors.lightGreen;
const Color green2 = Colors.green;
const Color blueColor = Color(0xFF1152FD);

const Color greenColor = Color(0xFF00c497);
//const Color greyColor = Colors.grey;

TextStyle textStyleSmall = const TextStyle(
    color: Color.fromRGBO(255, 255, 255, 0.8),
    fontSize: 12.0,
    fontFamily: "Roboto",
    fontWeight: FontWeight.bold);

//Image miniLogo = Image(
//    image: ExactAssetImage("assets/header-logo.png"),
//    height: 28.0,
//    width: 20.0,
//    alignment: FractionalOffset.center);

TextStyle headingWhite = const TextStyle(
  color: Colors.black,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle headingWhite18 = const TextStyle(
  color: Colors.white,
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle headingRed = const TextStyle(
  color: redColor,
  fontSize: 22.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle headingGrey = const TextStyle(
  color: Colors.grey,
  fontSize: 22.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle heading18 = const TextStyle(
  color: Colors.white,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontFamily: "OpenSans",
);

TextStyle heading18Black = const TextStyle(
  color: blackColor,
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle headingBlack = const TextStyle(
  color: blackColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle headingPrimaryColor = const TextStyle(
  color: primaryColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle headingLogo = const TextStyle(
  color: blackColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle heading35 = const TextStyle(
  color: Colors.white,
  fontSize: 35.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

TextStyle heading35Black = const TextStyle(
  color: blackColor,
  fontSize: 35.0,
  fontWeight: FontWeight.bold,
  fontFamily: "OpenSans",
);

const Color transparentColor = Color.fromRGBO(0, 0, 0, 0.2);
const Color activeButtonColor = Color.fromRGBO(43, 194, 137, 50.0);
const Color dangerButtonColor = Color(0XFFf53a4d);

int getColorHexFromStr(String colorStr) {
  colorStr = "FF$colorStr";
  colorStr = colorStr.replaceAll("#", "");
  int val = 0;
  int len = colorStr.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = colorStr.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw const FormatException("An error occurred when converting a color");
    }
  }
  return val;
}
