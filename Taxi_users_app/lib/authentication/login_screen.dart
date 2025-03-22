// ignore_for_file: prefer_const_constructors, unnecessary_string_escapes, unused_local_variable, avoid_web_libraries_in_flutter, unused_import, use_build_context_synchronously

//import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taxi_users_app/authentication/signup_screen.dart';
import 'package:taxi_users_app/global/global_var.dart';
import 'package:taxi_users_app/intro_screen/intro_screen.dart';
import 'package:taxi_users_app/methods/common_methods.dart';
import 'package:taxi_users_app/pages/home_page.dart';
import 'package:taxi_users_app/pages/service_selection_page.dart';
import 'package:taxi_users_app/widgets/loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworksAvailable() {
    //cMethods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Vui lòng điền email hợp lệ", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(
          "Mật khẩu của bạn phải có ít nhất 6 ký tự trở lên", context);
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Cho phép bạn đăng nhập..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
    // ignore: body_might_complete_normally_catch_error
        .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => ServiceSelectionPage()));
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar(
                "Bạn đã bị chặn. Vui lòng liên hệ admin: admin@gmail.com.", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar(
              "Tài khoản của bạn không phải tài khoản người dùng.", context);
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Image.asset("assets/images/logo2.png",
                height: 120, // Đặt chiều cao của ảnh
                width: 120,  // Đặt chiều rộng của ảnh
                fit: BoxFit.contain, // Đảm bảo ảnh không bị cắt, căn chỉnh đúng tỉ lệ
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "ĐĂNG NHẬP",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //Text fields + button dang ky
              Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email người dùng",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true, //che giấu nội dung người dùng nhập vào
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Mật khẩu",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 32,
                      ),

                      //nút đăng ký
                      ElevatedButton(
                        onPressed: () {
                          checkIfNetworksAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple, //màu nền màu tím
                            padding: EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical:
                                10) //horizontal: chieu ngang va vertical: chieu doc
                        ),
                        child: const Text("Đăng nhập"),
                      ),
                    ],
                  )),

              //const SizedBox(height: 12,),

              // Form đăng nhập bằng số điện thoại
              //const PhoneAuthentication(),

              //SizedBox(height: 10),
              //textbutton
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SignUpScreen()));
                },
                child: const Text(
                  "Bạn chưa có Tài khoản? Đăng ký tại đây",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
