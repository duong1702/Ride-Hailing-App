import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taxi_users_app/authentication/login_screen.dart';



import '../themes/style.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  SwiperController? _controller;
  int currentIndex = 0;
  Map<Permission, PermissionStatus>? permissions;
  Map<Permission, PermissionStatus>? permissionRequestResult;
  PermissionStatus? permission;
  bool isGrantedLocation = false;

  List<Map<String, dynamic>> listItem = [
    {"id": '0',"title" : 'AN TOÀN',"description" : "","image" : "assets/images/image_taxi_1.png"},
    {"id": '1',"title" : 'NHANH CHÓNG',"description" : "","image" : "assets/images/image_taxi_2.png"},
    {"id": '2',"title" : 'TIỆN LỢI',"description" : "","image" : "assets/images/image_taxi_3.png"},
  ];

  Future<void> requestPermission() async {
//    permissions = await PermissionHandler().requestPermissions([PermissionGroup.location]);
    isGrantedLocation = await Permission.location.request().isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: screenSize.height*0.09,left: screenSize.width*0.1,right: screenSize.width*0.1),
            child: Column(
              children: <Widget>[
                Text("${listItem[currentIndex]['title']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: Text("${listItem[currentIndex]['description']}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: screenSize.height*0.58,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20.0),
              child: Swiper(
                curve: Curves.easeInOut,
                controller: _controller,
                itemCount: 3,
                itemHeight: 200.0,
                viewportFraction: 0.6,
                scale: 0.6,
                loop: false,
                outer: true,
                index: currentIndex,
                onIndexChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(listItem[index]['image'],),
                        fit: BoxFit.cover
                      ),
                      borderRadius: BorderRadius.circular(10.0)
                    ),
                  );
                },
                pagination: SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: DotSwiperPaginationBuilder(
                        size: 5.0,
                        activeSize: 10.0,
                        space: 5.0,
                        color: greyColor2,
                        activeColor: blackColor
                    )
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: currentIndex == 2
                ? Padding(
              padding: EdgeInsets.only(
                bottom: screenSize.height * 0.06,
                left: screenSize.width * 0.1,
                right: screenSize.width * 0.1,
              ),
              child: SizedBox(
                width: 180,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Tiếp tục với App',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          )

        ],
      ),
    );
  }
}
