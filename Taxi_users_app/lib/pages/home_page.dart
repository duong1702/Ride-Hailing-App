// ignore_for_file: unnecessary_import, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:taxi_users_app/appInfo/app_info.dart';
import 'package:taxi_users_app/authentication/login_screen.dart';
import 'package:taxi_users_app/global/global_var.dart';
import 'package:taxi_users_app/global/trip_var.dart';
import 'package:taxi_users_app/methods/common_methods.dart';
import 'package:taxi_users_app/methods/manage_drivers_methods.dart';
import 'package:taxi_users_app/models/direction_details.dart';
import 'package:taxi_users_app/models/online_nearby_drivers.dart';
import 'package:taxi_users_app/pages/about_page.dart';
import 'package:taxi_users_app/pages/profile_page.dart';
import 'package:taxi_users_app/pages/screen_call.dart';
import 'package:taxi_users_app/pages/search_destination_page.dart';
import 'package:taxi_users_app/pages/trips_history_page.dart';
import 'package:taxi_users_app/widgets/loading.dart';
import 'package:taxi_users_app/widgets/payment_dialog.dart';
import 'package:taxi_users_app/widgets/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/push_notification_service.dart';
import '../widgets/info_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
  Completer<GoogleMapController>();

  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;

  //DateTime? tripTime;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;
  bool requestingDirectionDetailsInfo = false;
  String selectedVehicleType = ''; // Giá trị mặc định là "taxi"

  //get bottomMapPadding => null;

  makeDriverNearbyCarIcon() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration =
      createLocalImageConfiguration(context, size: const Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
          configuration, "assets/images/tracking.png")
          .then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes("themes/retro_style.json")
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition =
    CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await CommonMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
        currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
          });
        } else {
          FirebaseAuth.instance.signOut();

          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const LoginScreen()));

          cMethods.displaySnackBar(
              "Bạn đã bị chặn. Vui lòng liên hệ admin: admin@gmail.com.",
              context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  displayUserRideDetailsContainer() async {
    ///Directions API
    ///vẽ đường đi đón và trả khách
    await retrieveDirectionDetails();

    setState(() {
      //dùng lệnh setState để cập nhật lại giao diện
      searchContainerHeight = 0; //ẩn hộp tìm kiếm
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 250;
      isDrawerOpened = false;
    });
  }

  retrieveDirectionDetails() async //dùng hàm này sẽ lấy thông tin hướng đi giữa điểm đón và điểm trả khách.
      {
    var pickUpLocation =
        Provider
            .of<AppInfo>(context, listen: false)
            .pickUpLocation;
    var dropOffDestinationLocation =
        Provider
            .of<AppInfo>(context, listen: false)
            .dropOffLocation;

    var pickupGeoGraphicCoOrdinates = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffDestinationGeoGraphicCoOrdinates = LatLng(
        dropOffDestinationLocation!.latitudePosition!,
        dropOffDestinationLocation.longitudePosition!);

    showDialog(
      barrierDismissible: false, //không cho ngươi dùng tắt
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Nhận hướng đi..."),
    );

    ///Directions API
    //Hàm CommonMethods.getDirectionDetailsFromAPI() laasy tọa độ điểm đón và trả từ API
    var detailsFromDirectionAPI =
    await CommonMethods.getDirectionDetailsFromAPI(
        pickupGeoGraphicCoOrdinates,
        dropOffDestinationGeoGraphicCoOrdinates);
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination =
    pointsPolyline.decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);

    polylineCoOrdinates.clear();
    if (latLngPointsFromPickUpToDestination.isNotEmpty) {
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint) {
        polylineCoOrdinates
            .add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.pink,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    ///Tạo polyline cho phù hợp với bản đồ
    LatLngBounds boundsLatLng;
    if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude &&
        pickupGeoGraphicCoOrdinates.longitude >
            dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: dropOffDestinationGeoGraphicCoOrdinates,
        northeast: pickupGeoGraphicCoOrdinates,
      );
    } else if (pickupGeoGraphicCoOrdinates.longitude >
        dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
      );
    } else if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: pickupGeoGraphicCoOrdinates,
        northeast: dropOffDestinationGeoGraphicCoOrdinates,
      );
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    ///Thêm điểm đón và trả khách
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: dropOffDestinationLocation.placeName,
          snippet: "Destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });

    ///Thêm vòng kết nối giữa điểm ón và trả khách
    Circle pickUpPointCircle = Circle(
      circleId: const CircleId('pickupCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 2,
      radius: 14,
      center: pickupGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    Circle dropOffDestinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationPointCircle);
    });
  }

  resetAppNow() {
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = 'Tài xế đang đến';
    });
  }

  cancelRideRequest() {
    //Xóa yêu cầu đi xe khỏi cơ sở dữ liệu
    tripRequestRef!.remove();

    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    //Gửi yêu cầu đi xe
    makeTripRequest(selectedVehicleType);
  }

  updateAvailableNearbyOnlineDriversOnMap() {
    setState(() {
      markerSet.clear();
    });

    Set<Marker> markersTempSet = Set<Marker>();

    for (OnlineNearbyDrivers eachOnlineNearbyDriver
    in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(
          eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);

      Marker driverMarker = Marker(
        markerId: MarkerId(
            "driver ID = " + eachOnlineNearbyDriver.uidDriver.toString()),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      markerSet = markersTempSet;
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("onlineDrivers"); // Khởi tạo GeoFire

    Geofire.queryAtLocation(currentPositionOfUser!.latitude,
        currentPositionOfUser!.longitude, 22)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];

        switch (onlineDriverChild) {
          case Geofire.onKeyEntered:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];

            // Lấy vehicleType từ Firebase
            DatabaseReference driverRef = FirebaseDatabase.instance
                .ref()
                .child("drivers")
                .child(onlineNearbyDrivers.uidDriver!);

            driverRef.once().then((DatabaseEvent dataSnapshot) {
              // Check if dataSnapshot contains data using snapshot.value
              if (dataSnapshot.snapshot.value != null) {
                var driverData = dataSnapshot.snapshot.value as Map;
                onlineNearbyDrivers.vehicleType =
                driverData["vehicleType"]; // Lấy vehicleType từ Firebase
                print(
                    "Driver Added: ${onlineNearbyDrivers
                        .uidDriver}, Vehicle Type: ${onlineNearbyDrivers
                        .vehicleType}");
              } else {
                print("Driver data does not exist.");
              }

              // Thêm tài xế vào danh sách
              ManageDriversMethods.nearbyOnlineDriversList
                  .add(onlineNearbyDrivers);
              updateAvailableNearbyOnlineDriversOnMap(); // Cập nhật bản đồ
            });

            break;

          case Geofire.onKeyExited:
            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
            updateAvailableNearbyOnlineDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            ManageDriversMethods.updateOnlineNearbyDriversLocation(
                onlineNearbyDrivers);
            updateAvailableNearbyOnlineDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;
            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  void makeTripRequest(String vehicleType) {
    if (vehicleType.isEmpty) {
      // Nếu chưa chọn loại xe, thông báo lỗi
      cMethods.displaySnackBar(
          "Vui lòng chọn loại xe trước khi đặt chuyến", context);
      return;
    }

    tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequests").push();

    var pickUpLocation =
        Provider
            .of<AppInfo>(context, listen: false)
            .pickUpLocation;
    var dropOffDestinationLocation =
        Provider
            .of<AppInfo>(context, listen: false)
            .dropOffLocation;

    Map pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map dropOffDestinationCoOrdinatesMap = {
      "latitude": dropOffDestinationLocation!.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map driverCoOrdinates = {
      "latitude": "",
      "longitude": "",
    };

    // Tạo dữ liệu chuyến đi
    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffDestinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,
      "vehicleType": vehicleType, // Lưu loại xe được chọn
      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new",
    };

    // Gửi yêu cầu lên Firebase
    tripRequestRef!.set(dataMap);

    // Lắng nghe sự kiện thay đổi từ Firebase
    tripStreamSubscription =
        tripRequestRef!.onValue.listen((eventSnapshot) async {
          if (eventSnapshot.snapshot.value == null) {
            return;
          }

          final Map tripData = Map<String, dynamic>.from(
              eventSnapshot.snapshot.value as Map<dynamic, dynamic>);

          if ((eventSnapshot.snapshot.value as Map)["driverName"] != null) {
            nameDriver = (eventSnapshot.snapshot.value as Map)["driverName"];
          }

          if ((eventSnapshot.snapshot.value as Map)["driverPhone"] != null) {
            phoneNumberDriver =
            (eventSnapshot.snapshot.value as Map)["driverPhone"];
          }

          if ((eventSnapshot.snapshot.value as Map)["driverPhoto"] != null) {
            photoDriver = (eventSnapshot.snapshot.value as Map)["driverPhoto"];
          }

          if ((eventSnapshot.snapshot.value as Map)["carDetails"] != null) {
            carDetailsDriver =
            (eventSnapshot.snapshot.value as Map)["carDetails"];
          }

          if ((eventSnapshot.snapshot.value as Map)["status"] != null) {
            status = (eventSnapshot.snapshot.value as Map)["status"];
          }

          if ((eventSnapshot.snapshot.value as Map)["driverLocation"] != null) {
            double driverLatitude = double.parse(
                (eventSnapshot.snapshot
                    .value as Map)["driverLocation"]["latitude"]
                    .toString());
            double driverLongitude = double.parse(
                (eventSnapshot.snapshot
                    .value as Map)["driverLocation"]["longitude"]
                    .toString());
            LatLng driverCurrentLocationLatLng =
            LatLng(driverLatitude, driverLongitude);

            if (status == "accepted") {
              //cập nhật thông tin điểm đón cho người dùng trên giao diện người dùng
              //Thông tin từ vị trí hiện tại của tài xế đến địa điểm đón của người dùng
              updateFromDriverCurrentLocationToPickUp(
                  driverCurrentLocationLatLng);
            } else if (status == "arrived") {
              //Cập nhật thông tin đã đến - khi tài xế đến điểm đón của người dùng
              setState(() {
                tripStatusDisplay = 'Tài xế đã đến';
              });
            } else if (status == "ontrip") {
              //cập nhật thông tin để bỏ qua cho người dùng trên giao diện người dùng
              //Thông tin từ vị trí hiện tại của tài xế đến địa điểm trả khách của người dùng
              updateFromDriverCurrentLocationToDropOffDestination(
                  driverCurrentLocationLatLng);
            }
          }

          if (status == "accepted") {
            displayTripDetailsContainer();

            Geofire.stopListener();

            //remove drivers markers
            setState(() {
              markerSet.removeWhere(
                      (element) => element.markerId.value.contains("driver"));
            });
          }

          if (status == "ended") {
            if (tripData["fareAmount"] != null) {
              // Lấy số tiền fareAmount từ tripData
              double fareAmount = double.parse(
                  tripData["fareAmount"].toString());

              // Hiển thị hộp thoại thanh toán
              var responseFromPaymentDialog = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PaymentDialog(fareAmount: fareAmount.toString(),);
                },
              );

              // Kiểm tra nếu người dùng đã hoàn tất thanh toán
              if (responseFromPaymentDialog == "paid") {
                // Hiển thị hộp thoại đánh giá
                var responseFromRatingDialog = await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      RatingDialog(
                        tripID: tripRequestRef!.key!, // ID của chuyến đi
                        driverID: tripData["driverID"],
                        userID: tripData["userID"], // ID của tài xế
                      ),
                );

                // Sau khi người dùng hoàn thành đánh giá, thực hiện reset ứng dụng
                if (responseFromRatingDialog == true) {
                  // Ngắt kết nối các tài nguyên liên quan đến chuyến đi
                  tripRequestRef!.onDisconnect();
                  tripRequestRef = null;

                  tripStreamSubscription!.cancel();
                  tripStreamSubscription = null;

                  resetAppNow();

                  // Khởi động lại ứng dụng
                  Restart.restartApp();
                }
              }
            }
          }
        });
  }

  displayTripDetailsContainer() {
    setState(() {
      requestContainerHeight = 0;
      tripContainerHeight = 291;
      bottomMapPadding = 281;
    });
  }

  updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var userPickUpLocationLatLng = LatLng(
          currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

      var directionDetailsPickup =
      await CommonMethods.getDirectionDetailsFromAPI(
          driverCurrentLocationLatLng, userPickUpLocationLatLng);

      if (directionDetailsPickup == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
        "Tài xế đang đến - ${directionDetailsPickup.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  updateFromDriverCurrentLocationToDropOffDestination(
      driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var dropOffLocation =
          Provider
              .of<AppInfo>(context, listen: false)
              .dropOffLocation;
      var userDropOffLocationLatLng = LatLng(dropOffLocation!.latitudePosition!,
          dropOffLocation.longitudePosition!);

      var directionDetailsPickup =
      await CommonMethods.getDirectionDetailsFromAPI(
          driverCurrentLocationLatLng, userDropOffLocationLatLng);

      if (directionDetailsPickup == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
        "Tài xế đang trong chuyến đi - ${directionDetailsPickup
            .durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  noDriverAvailable() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            InfoDialog(
              title: "Không có tài xế",
              description:
              "Không tìm thấy tài xế nào ở vị trí gần đó. Vui lòng thử lại sau.",
            ));
  }

  ///Tìm  kiếm  tài xế
  void searchDriver() {
    print("Selected Vehicle Type: $selectedVehicleType");
    print("Available Drivers List: $availableNearbyOnlineDriversList");

    if (availableNearbyOnlineDriversList == null ||
        availableNearbyOnlineDriversList!.isEmpty) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    // Lọc tài xế theo loại xe đã chọn
    var filteredDrivers = availableNearbyOnlineDriversList!.where((driver) {
      print("Checking driver vehicle type: ${driver.vehicleType}");
      return driver.vehicleType ==
          selectedVehicleType; // Lọc tài xế theo vehicleType
    }).toList();

    print("Filtered Drivers: $filteredDrivers");

    if (filteredDrivers.isEmpty) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    // Chọn tài xế đầu tiên trong danh sách đã lọc
    var currentDriver = filteredDrivers[0];

    // Gửi thông báo tới tài xế hiện tại
    sendNotificationToDriver(currentDriver);

    // Xóa tài xế đã chọn khỏi danh sách
    availableNearbyOnlineDriversList!.removeAt(0);
  }

  sendNotificationToDriver(OnlineNearbyDrivers currentDriver) {
    //cập nhật newTripStatus của tài xế - gán tripID cho tài xế hiện tại
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");

    currentDriverRef.set(tripRequestRef!.key);

    //Nhận mã thông báo nhận dạng tài xế hiện tại
    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        //gửi thông báo
        PushNotificationService.sendNotificationToSelectedDriver(
            deviceToken, context, tripRequestRef!.key.toString());
      } else {
        return;
      }
      const oneTickPerSec = Duration(seconds: 1);

      var timerCountDown = Timer.periodic(oneTickPerSec, (timer) {
        requestTimeoutDriver = requestTimeoutDriver - 1;

        //khi yêu cầu chuyến đi không được yêu cầu có nghĩa là yêu cầu chuyến đi đã bị hủy - dừng bộ đếm thời gian
        if (stateOfApp != "requesting") {
          timer.cancel();
          currentDriverRef.set("cancelled");
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;
        }

        //khi yêu cầu chuyến đi được chấp nhận bởi tài xế gần nhất trực tuyến
        currentDriverRef.onValue.listen((dataSnapshot) {
          if (dataSnapshot.snapshot.value.toString() == "accepted") {
            timer.cancel();
            currentDriverRef.onDisconnect();
            requestTimeoutDriver = 20;
          }
        });

        //nếu 20 giây trôi qua - se gửi thông báo đến tài xế trực tuyến gần nhất có sẵn
        if (requestTimeoutDriver == 0) {
          currentDriverRef.set("timeout");
          timer.cancel();
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;

          //gửi thông báo đến tài xế trực tuyến gần nhất có dang online
          searchDriver();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcon();

    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: Colors.black87,
        child: Drawer(
          backgroundColor: Colors.white10,
          child: ListView(
            children: [
              //header
              Container(
                color: Colors.black,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/avatarwoman.webp",
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Thông tin cá nhân",
                            style: TextStyle(
                              color: Colors.white10,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const Divider(
                height: 1,
                color: Colors.white,
                thickness: 1,
              ),

              const SizedBox(
                height: 10,
              ),
              //body

              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const ProfilePage()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "Hồ sơ",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const TripsHistoryPage()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.history,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "Lịch sử chuyến đi",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const AboutPage()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "Thông tin",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "Đăng xuất",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [

          ///google map
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            //có thể thay thế loại bản đồ như bản đồ địa hình(hybird)...
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;

              updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 120;
              });

              getCurrentLiveLocationOfUser();
            },
          ),

          ///Drawer button
          Positioned(
            top: 36,
            left: 19,
            child: GestureDetector(
              onTap: () {
                if (isDrawerOpened == true) {
                  sKey.currentState!.openDrawer();
                } else {
                  resetAppNow();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(
                    isDrawerOpened == true ? Icons.menu : Icons.close,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          ///tim kiem
          Positioned(
            left: 0,
            right: 0,
            bottom: -80,
            child: Container(
              height: searchContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      var responseFromSearchPage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const SearchDestinationPage()));

                      if (responseFromSearchPage == "placeSelected") {
                        displayUserRideDetailsContainer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15)),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const TripsHistoryPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15)),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),

          ///tim kiem

          ///chi tiết chuyến đi
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: rideDetailsContainerHeight, // Sử dụng giá trị động
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề và nút "View All"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Đề xuất dịch vụ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện khi nhấn nút "View All"
                          },
                          child: const Row(
                            children: [
                              Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.expand_more,
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Row chọn loại xe (Taxi hoặc Xe tải)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Radio Button cho Taxi
                        Row(
                          children: [
                            Radio<String>(
                              value: 'taxi',
                              groupValue: selectedVehicleType,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedVehicleType = value!;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                            const Text(
                              "Taxi",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        // Radio Button cho Xe tải
                        Row(
                          children: [
                            Radio<String>(
                              value: 'truck',
                              groupValue: selectedVehicleType,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedVehicleType = value!;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                            const Text(
                              "Xe tải",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Thông tin loại xe và khoảng cách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/Taxi1.png", // Icon xe tiêu chuẩn
                              height: 40,
                              width: 70,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              selectedVehicleType == 'taxi'
                                  ? '4 chỗ'
                                  : 'Xe tải',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          tripDirectionDetailsInfo != null
                              ? tripDirectionDetailsInfo!.distanceTextString!
                              : "0 km",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tripDirectionDetailsInfo != null
                                  ? "${cMethods.calculateFareAmount(
                                  tripDirectionDetailsInfo!).toString()} VND"
                                  : "0 VND",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tripDirectionDetailsInfo != null
                                    ? tripDirectionDetailsInfo!
                                    .durationTextString!
                                    : "0 mins",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nút "Book Now"
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            stateOfApp = "requesting";
                          });

                          displayRequestContainer();

                          // Gọi hàm makeTripRequest và truyền vehicleType vào
                          makeTripRequest(selectedVehicleType);

                          // Lọc tài xế gần nhất theo loại xe (vehicleType)
                          availableNearbyOnlineDriversList =
                              ManageDriversMethods
                                  .nearbyOnlineDriversList
                                  .where((driver) =>
                              driver.vehicleType ==
                                  selectedVehicleType) // Sử dụng .vehicleType thay vì []
                                  .toList();

                          searchDriver(); // Tìm tài xế
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Đặt Xe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          ///
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: 200,
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        resetAppNow();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1.5, color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///chi tiết chuyến đi
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: tripContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white24,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),

                    //trip status display text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tripStatusDisplay,
                          style: const TextStyle(
                            fontSize: 19,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 19,
                    ),

                    const Divider(
                      height: 1,
                      color: Colors.white70,
                      thickness: 1,
                    ),

                    const SizedBox(
                      height: 19,
                    ),

                    //image - driver name and driver car details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.network(
                            photoDriver == ''
                                ? "https://firebasestorage.googleapis.com/v0/b/bookingapp-19efc.appspot.com/o/avatarman.png?alt=media&token=52b681e0-f3d2-42bc-b3e8-65b20b3e4bf3"
                                : photoDriver,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameDriver,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              carDetailsDriver,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 19,
                    ),

                    const Divider(
                      height: 1,
                      color: Colors.white70,
                      thickness: 1,
                    ),

                    const SizedBox(
                      height: 19,
                    ),

                    //call driver btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse("tel://$phoneNumberDriver"));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 11,
                              ),
                              const Text(
                                "Call",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        // Message Button
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse("sms://$phoneNumberDriver"));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25)),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.message,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 11,
                              ),
                              const Text(
                                "Message",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

