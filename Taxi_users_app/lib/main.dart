// ignore_for_file: unused_import, prefer_const_constructors
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:taxi_users_app/appInfo/app_info.dart';
import 'package:taxi_users_app/authentication/login_screen.dart';
import 'package:taxi_users_app/authentication/signup_screen.dart';
import 'package:taxi_users_app/global/global_var.dart';
import 'package:taxi_users_app/intro_screen/intro_screen.dart';
import 'package:taxi_users_app/pages/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taxi_users_app/pages/service_selection_page.dart';
import 'package:taxi_users_app/pages/truck_booking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDmOjP17oJ4-cabYB2V1Eos7PAEThUCVAo",
            authDomain: "bookingapp-19efc.firebaseapp.com",
            projectId: "bookingapp-19efc",
            storageBucket: "bookingapp-19efc.appspot.com",
            messagingSenderId: "262205626491",
            appId: "1:262205626491:web:36d625ab571ad6363ceade",
            measurementId: "G-HVZXW4XC7V"));
  } else {
    await Firebase.initializeApp();
  }

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission){
    if(valueOfPermission){
      Permission.locationWhenInUse.request();
    }
  }
  );
  await initializeDateFormatting('vi', null);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale("vi"),
        Locale("en"),
      ],
      path: "assets/translations",
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter User App',
        debugShowCheckedModeBanner: false, // Xóa banner debug mặc định trên ứng dụng
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        navigatorKey: navigatorKey,
        initialRoute: FirebaseAuth.instance.currentUser == null ? '/intro' : '/service_selection',
        routes: {
          '/intro': (context) => IntroScreen(), // Màn hình giới thiệu
          '/service_selection': (context) => ServiceSelectionPage(), // Màn hình chọn dịch vụ
          '/taxi_booking': (context) => HomePage(), // Trang đặt xe taxi
          '/truck_booking': (context) => TruckBookingPage(), // Trang đặt xe tải
        },
      ),
    );
  }
}
