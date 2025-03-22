import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController carTextEditingController = TextEditingController();

  final DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
  bool isEditing = false;

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = driverName;
      phoneTextEditingController.text = driverPhone;
      emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email.toString();
      carTextEditingController.text = "$carNumber - $carColor - $carModel";
    });
  }

  updateDriverInfo() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    Map<String, String> updatedData = {
      "name": nameTextEditingController.text.trim(),
      "phone": phoneTextEditingController.text.trim(),
      "car_details": carTextEditingController.text.trim(),
    };

    await driversRef.child(currentUserId).update(updatedData).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thành công!")),
      );

      setState(() {
        driverName = updatedData["name"]!;
        driverPhone = updatedData["phone"]!;
        List<String> carDetails = updatedData["car_details"]!.split(" - ");
        carNumber = carDetails[0];
        carColor = carDetails[1];
        carModel = carDetails[2];
        isEditing = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thất bại!")),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin tài xế"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                updateDriverInfo();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: NetworkImage(
                      driverPhoto,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                child: TextField(
                  controller: nameTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: isEditing,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              // Phone Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                child: TextField(
                  controller: phoneTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: isEditing,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_android_outlined, color: Colors.white),
                  ),
                ),
              ),
              // Car Info Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                child: TextField(
                  controller: carTextEditingController,
                  textAlign: TextAlign.center,
                  enabled: isEditing,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.drive_eta_rounded, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                ),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
