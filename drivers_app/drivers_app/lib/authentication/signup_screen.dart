// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../methods/common_methods.dart';
import '../pages/dashboard.dart';
import '../widgets/loading.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController mauXeTextEditingController = TextEditingController();
  TextEditingController hangXeTextEditingController = TextEditingController();
  TextEditingController bienSoXeTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  XFile? imageFile;
  String urlOfUploadedImage = "";
  String? selectedVehicleType;

  final List<String> vehicleTypes = ['taxi', 'truck'];

  // Kiểm tra mạng và hình ảnh trước khi đăng ký
  checkIfNetworkIsAvailable() {
    if (imageFile != null) {
      signUpFormValidation();
    } else {
      cMethods.displaySnackBar("Vui lòng chọn hình ảnh", context);
    }
  }

  // Kiểm tra form đăng ký
  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("Tên của bạn phải có ít nhất 3 ký tự", context);
    } else if (userPhoneTextEditingController.text.trim().length < 8 ||
        !RegExp(r'^[0-9]+$').hasMatch(userPhoneTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Số điện thoại phải có ít nhất 8 ký tự và chỉ chứa số", context);
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Vui lòng nhập email hợp lệ", context);
    } else if (passwordTextEditingController.text.trim().length < 6 ||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(passwordTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Mật khẩu phải có ít nhất 6 ký tự, chứa một chữ cái và một số", context);
    } else if (selectedVehicleType == null) {
      cMethods.displaySnackBar("Vui lòng chọn loại xe của bạn", context);
    } else if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(mauXeTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Màu xe chỉ được chứa chữ cái và khoảng trắng", context);
    } else if (bienSoXeTextEditingController.text.trim().isEmpty ||
        !RegExp(r'^[0-9]{2}[A-Z]-[0-9]{4,5}$').hasMatch(bienSoXeTextEditingController.text.trim())) {
      cMethods.displaySnackBar("Biển số xe không hợp lệ. VD: 30A-12345", context);
    } else {
      uploadImageToStorage();
    }
  }


  // Tải hình ảnh lên Firebase Storage
  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Hinh anh").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });
    registerNewDriver();
  }

  // Đăng ký tài xế mới vào Firebase Auth và lưu vào Realtime Database
  registerNewDriver() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Đang đăng ký tài khoản..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
        .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef =
    FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

    Map driverCarInfo = {
      "carColor": mauXeTextEditingController.text.trim(),
      "carModel": hangXeTextEditingController.text.trim(), // Loại xe đã chọn
      "carNumber": bienSoXeTextEditingController.text.trim(),
    };

    Map driverDataMap = {
      "photo": urlOfUploadedImage,
      "car_details": driverCarInfo,
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "vehicleType": selectedVehicleType,
      "blockStatus": "no",
    };

    usersRef.set(driverDataMap);
    Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
  }

  // Chọn hình ảnh từ thư viện
  chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  Widget buildVehicleTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedVehicleType,
      decoration: const InputDecoration(
        labelText: "Loại xe",
        labelStyle: TextStyle(fontSize: 14),
      ),
      items: vehicleTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedVehicleType = newValue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 30),
              imageFile == null
                  ? const CircleAvatar(
                radius: 76,
                backgroundImage: AssetImage("assets/images/avatarman.png"),
              )
                  : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(File(imageFile!.path)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "Chọn hình ảnh",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      decoration: const InputDecoration(labelText: "Tên tài xế"),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhoneTextEditingController,
                      decoration: const InputDecoration(labelText: "Số điện thoại"),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailTextEditingController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Mật khẩu"),
                    ),
                    const SizedBox(height: 22),
                    buildVehicleTypeDropdown(),
                    const SizedBox(height: 22),
                    TextField(
                      controller: mauXeTextEditingController,
                      decoration: const InputDecoration(labelText: "Màu xe"),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: hangXeTextEditingController,
                      decoration: const InputDecoration(labelText: "Hãng Xe"),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: bienSoXeTextEditingController,
                      decoration: const InputDecoration(labelText: "Biển số xe"),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      ),
                      child: const Text("ĐĂNG KÝ"),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Bạn đã có tài khoản? Đăng nhập tại đây",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
