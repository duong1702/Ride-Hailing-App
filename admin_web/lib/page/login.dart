import 'package:admin_web/dashboard/side_navigation_drawer.dart';
import 'package:flutter/material.dart';


class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Thiết lập sẵn email và mật khẩu của admin
  final String adminEmail = "admin@gmail.com";
  final String adminPassword = "admin123";

  // Kiểm tra thông tin đăng nhập
  void _checkAdminLogin() {
    String enteredEmail = emailController.text.trim();
    String enteredPassword = passwordController.text.trim();

    // Kiểm tra nếu email và mật khẩu đúng
    if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
      // Đăng nhập thành công, điều hướng tới trang quản trị
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SideNavigationDrawer()),  // Thay AdminPage bằng trang quản trị của bạn
      );
    } else {
      // Nếu đăng nhập sai, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Email hoặc mật khẩu không chính xác!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng nhập Quản trị viên"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400), // Giới hạn chiều rộng của form
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Đảm bảo chiều cao chỉ vừa đủ form
                children: [
                  Image.asset(
                    "images/admin-icon.jpg",
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "ĐĂNG NHẬP",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _checkAdminLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                    ),
                    child: const Text("Đăng nhập"),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Nếu cần, có thể thêm một trang đăng ký cho admin ở đây
                      print("Đăng ký Admin nếu cần");
                    },
                    child: const Text(
                      "Bạn chưa có tài khoản? Đăng ký tại đây",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
