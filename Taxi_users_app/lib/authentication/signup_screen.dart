// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taxi_users_app/authentication/login_screen.dart';
import 'package:taxi_users_app/methods/common_methods.dart';
import 'package:taxi_users_app/pages/home_page.dart';
import 'package:taxi_users_app/widgets/loading.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().isEmpty ||
        userPhoneTextEditingController.text.trim().isEmpty ||
        emailTextEditingController.text.trim().isEmpty ||
        passwordTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar("Vui lòng điền đầy đủ tất cả các thông tin", context);
    } else if (userNameTextEditingController.text.trim().length < 3 ||
        !RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(userNameTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Tên người dùng chỉ được chứa chữ cái và ít nhất 3 ký tự", context);
    } else if (!RegExp(r'^[0-9]+$').hasMatch(userPhoneTextEditingController.text.trim()) ||
        userPhoneTextEditingController.text.trim().length < 8) {
      cMethods.displaySnackBar("Số điện thoại phải chứa ít nhất 8 chữ số và chỉ được là số", context);
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Vui lòng nhập địa chỉ email hợp lệ", context);
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$')
        .hasMatch(passwordTextEditingController.text.trim())) {
      cMethods.displaySnackBar(
          "Mật khẩu phải có ít nhất 6 ký tự, bao gồm cả chữ cái và số", context);
    } else {
      registerNewUser();
    }
  }


  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Đăng ký tài khoản của bạn..."),
    );
    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
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

    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap = {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
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
                "Tạo tài khoản người dùng",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //Text fields + button dang ky
              Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: userNameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Tên người dùng",
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
                        controller: userPhoneTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Số điện thoại",
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
                        obscureText:
                            true, //che giấu nội dung người dùng nhập vào
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
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple, //màu nền màu tím
                            padding: EdgeInsets.symmetric(
                                horizontal: 80,
                                vertical:
                                    10) //horizontal: chieu ngang va vertical: chieu doc
                            ),
                        child: const Text("ĐĂNG KÝ"),
                      ),
                    ],
                  )),

              const SizedBox(
                height: 12,
              ),

              //textbutton
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Bạn đã có Tài khoản? Đăng nhập tại đây",
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
