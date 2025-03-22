import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taxi_users_app/global/global_var.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();

  bool isEditing = false;

  // Lấy thông tin người dùng từ biến toàn cục
  setUserInfo() {
    setState(() {
      nameTextEditingController.text = userName;
      phoneTextEditingController.text = userPhone;
      emailTextEditingController.text = FirebaseAuth.instance.currentUser!.email.toString();
    });
  }

  // Cập nhật thông tin người dùng lên Firebase
  updateUserInfo() async {
    try {
      setState(() {
        userName = nameTextEditingController.text;
        userPhone = phoneTextEditingController.text;
      });

      // Cập nhật Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid);
      await userRef.update({
        'name': userName,
        'phone': userPhone,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thông tin thành công!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xảy ra lỗi!")));
    }
  }

  @override
  void initState() {
    super.initState();
    setUserInfo(); // Lấy thông tin người dùng khi mở màn hình
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Thông tin cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing; // Chuyển đổi chế độ chỉnh sửa
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Avatar và thông tin người dùng
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 60,
                        child: Image.asset("assets/images/avatarwoman.webp"),
                    ),
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                        onPressed: () {
                          // Xử lý thay đổi ảnh đại diện
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tên người dùng
              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: "Tên",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                enabled: isEditing, // Chỉ cho phép chỉnh sửa khi isEditing == true
              ),
              const SizedBox(height: 15),

              // Số điện thoại
              TextField(
                controller: phoneTextEditingController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 15),

              // Email người dùng
              TextField(
                controller: emailTextEditingController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                enabled: false, // Email không thể chỉnh sửa
              ),
              const SizedBox(height: 20),

              // Nút cập nhật thông tin
              if (isEditing)
                ElevatedButton(
                  onPressed: () {
                    updateUserInfo();
                    setState(() {
                      isEditing = false; // Sau khi cập nhật, chuyển về chế độ xem
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.pink,
                  ),
                  child: const Text("Cập nhật thông tin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (!isEditing)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true; // Chuyển sang chế độ chỉnh sửa
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.pink,
                  ),
                  child: const Text("Chỉnh sửa thông tin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
