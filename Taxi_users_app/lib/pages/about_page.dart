import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  // Hàm mở Facebook
  Future<void> _launchFacebook() async {
    const facebookUrl = 'https://www.facebook.com/profile.php?id=100063718998545'; // Thay "yourpage" bằng tên trang Facebook của bạn
    if (await canLaunch(facebookUrl)) {
      await launch(facebookUrl);
    } else {
      throw 'Không thể mở trang Facebook';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Về Chúng Tôi",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                "assets/images/logo.png",
                height: 150,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Ứng dụng Taxi Người Dùng",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Ứng dụng này được phát triển bởi Duong Pham với mục tiêu cung cấp dịch vụ di chuyển nhanh chóng, tiện lợi và an toàn cho người dùng tại Việt Nam.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Features Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tính Năng Chính:",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "- Đặt xe nhanh chóng.\n- Theo dõi tài xế trực tiếp trên bản đồ.\n- Thanh toán tiện lợi qua ví điện tử.\n- Hỗ trợ 24/7.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Contact Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Liên Hệ Với Chúng Tôi:",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "- Email: duongpham@example.com\n- Hotline: 0987 654 321\n- Địa chỉ: Quận 1, TP. Hồ Chí Minh, Việt Nam",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Social Media Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Theo Dõi Chúng Tôi:",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _launchFacebook,  // Gọi hàm mở Facebook
                        icon: const Icon(Icons.facebook, color: Colors.blue, size: 32),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt, color: Colors.pink, size: 32),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.alternate_email, color: Colors.lightBlue, size: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            const Text(
              "© 2024 Duong Pham. All Rights Reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
