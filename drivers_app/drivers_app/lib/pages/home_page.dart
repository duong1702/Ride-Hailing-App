import 'dart:async';
//import 'dart:convert';
//import 'dart:typed_data';

import 'package:drivers_app/methods/map_theme_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';
import '../pushNotification/push_notification_system.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver; //Vị trí GPS hiện tại của tài xế.
  Color colorToShow = Colors.green;
  String titleToShow = "TRUY CẬP NGAY";
  bool isDriverAvailable = false; //Biến boolean xác định tài xế đang online hay offline.
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();



  getCurrentLiveLocationOfDriver() async{
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatLng = LatLng(currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow()
  {
    // Khởi tạo Geofire để quản lý vị trí
    Geofire.initialize("onlineDrivers");

   // Cập nhật vị trí của tài xế trên Geofire
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid, //id tài xế
      currentPositionOfDriver!.latitude, // vĩ độ
      currentPositionOfDriver!.longitude, //kinh độ
    );

    // Lưu trạng thái online trong Firebase Database dưới dạng waiting
    newTripRequestReference = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    // Lắng nghe thay đổi trạng thái (nếu cần)
    newTripRequestReference!.onValue.listen((event) { });
  }
///Cập nhật địa điểm
  setAndGetLocationUpdates()
  {
    positionStreamHomePage = Geolocator.getPositionStream()
        .listen((Position position)
    {
      currentPositionOfDriver = position;

      if(isDriverAvailable == true)
      {
        //Cập nhật vị trí mới vào Geofire bằng Geofire.setLocation().
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  ///Ngừng chia sẻ và cập nhật vị trí khi ti xế offline
  goOfflineNow()
  {
    // Xóa vị trí của tài xế khỏi Geofire và Ngừng chia sẻ vị trí trực tiếp của tài xế
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //Ngừng nhận chuyến đi mới
    newTripRequestReference!.onDisconnect(); //// Tự động xóa trạng thái khi tài xế ngắt kết nối
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem()
  {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  retrieveCurrentDriverInfo() async
  {
    await FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once().then((snap)
    {
      driverName = (snap.snapshot.value as Map)["name"];
      driverPhone = (snap.snapshot.value as Map)["phone"];
      driverPhoto = (snap.snapshot.value as Map)["photo"];
      carColor = (snap.snapshot.value as Map)["car_details"]["carColor"];
      carModel = (snap.snapshot.value as Map)["car_details"]["carModel"];
      carNumber = (snap.snapshot.value as Map)["car_details"]["carNumber"];
    });

    initializePushNotificationSystem();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ///Google map
          GoogleMap(
            padding: const EdgeInsets.only(top: 136),
            mapType: MapType.normal, //có thể thay thế loại bản đồ như bản đồ địa hình(hybird)...
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;

              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLiveLocationOfDriver();
            },
          ),
          ///Google map

          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),

          ///Nút Truy cập trực tuyến ngoại tuyến
          Positioned(
            top: 61,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: ()
                  {
                    showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        builder: (BuildContext context)
                        {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              boxShadow:
                              [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(
                                    0.7,
                                    0.7,
                                  ),
                                ),
                              ],
                            ),
                            height: 221,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                              child: Column(
                                children: [

                                  const SizedBox(height:  11,),

                                  Text(
                                    (!isDriverAvailable) ? "ONLINE NGAY" : "OFFLINE NGAY",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 21,),

                                  Text(
                                    (!isDriverAvailable)
                                        ? "Bạn chuẩn bị online, bạn sẽ sẵn sàng nhận yêu cầu chuyến đi từ người dùng."
                                        : "Bạn chuẩn bị offline, bạn sẽ ngừng nhận yêu cầu chuyến đi mới từ người dùng.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white30,
                                    ),
                                  ),

                                  const SizedBox(height: 25,),

                                  Row(
                                    children: [

                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: ()
                                          {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                              "TRỞ VỀ"
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16,),

                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: ()
                                          {
                                            if(!isDriverAvailable)
                                            {
                                              //go online
                                              goOnlineNow();
                                              //Nhận thông tin cập nhật về vị trí của tài xế
                                              setAndGetLocationUpdates();


                                              Navigator.pop(context);

                                              setState(() {
                                                colorToShow = Colors.pink;
                                                titleToShow = "OFFLINE NGAY";
                                                isDriverAvailable = true;
                                              });
                                            }
                                            else
                                            {
                                              //go offline
                                              goOfflineNow();

                                              Navigator.pop(context);

                                              setState(() {
                                                colorToShow = Colors.green;
                                                titleToShow = "ONLINE NGAY";
                                                isDriverAvailable = false;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: (titleToShow == "TRUY CẬP NGAY")
                                                ? Colors.green
                                                : Colors.pink,
                                          ),
                                          child: const Text(
                                              "XÁC NHẬN"
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),

                                ],
                              ),
                            ),
                          );
                        }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorToShow,
                  ),
                  child: Text(
                    titleToShow,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
