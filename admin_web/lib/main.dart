import 'package:admin_web/page/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'dashboard/side_navigation_drawer.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDmOjP17oJ4-cabYB2V1Eos7PAEThUCVAo",
        authDomain: "bookingapp-19efc.firebaseapp.com",
        databaseURL: "https://bookingapp-19efc-default-rtdb.firebaseio.com",
        projectId: "bookingapp-19efc",
        storageBucket: "bookingapp-19efc.appspot.com",
        messagingSenderId: "262205626491",
        appId: "1:262205626491:web:730db47393e40cf63ceade",
        measurementId: "G-86VGGFQD2K"
    )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin_web',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: AdminLoginScreen(),
    );
  }
}

