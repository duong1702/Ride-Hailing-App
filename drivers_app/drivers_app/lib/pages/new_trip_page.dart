import 'dart:async';

import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/methods/map_theme_methods.dart';
import 'package:drivers_app/models/trip_details.dart';
import 'package:drivers_app/widgets/payment_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global_var.dart';
import '../widgets/loading.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails? newTripDetailsInfo;

  const NewTripPage({
    super.key,
    this.newTripDetailsInfo,
  });

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;
  List<LatLng> coordinatesPolylineLatLngList =
      []; //Khởi tạo một danh sách rỗng để lưu các tọa độ (LatLng) của tuyến đường
  PolylinePoints polylinePoints =
      PolylinePoints(); //cung cấp phương thức decodePolyline để giải mã polyline.
  Set<Marker> markersSet =
      <Marker>{}; //Marker (đánh dấu trên bản đồ), như vị trí nguồn hoặc đích.
  Set<Circle> circlesSet = <Circle>{}; //Lưu các Circle (vòng tròn)
  Set<Polyline> polyLinesSet =
      <Polyline>{}; //Lưu các Polyline, tức là các đường nối giữa các điểm trên bản đồ để biểu diễn tuyến đường.
  BitmapDescriptor? carMarkerIcon;
  bool directionRequested = false;
  String statusOfTrip = "accepted";
  String durationText = "", distanceText = "";
  String buttonTitleText = "ĐẾN";
  Color buttonColor = Colors.indigoAccent;
  CommonMethods cMethods = CommonMethods();


  makeMarker() {
    if (carMarkerIcon == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: const Size(2, 2));

      BitmapDescriptor.asset(configuration, "assets/images/tracking.png")
          .then((valueIcon) {
        carMarkerIcon = valueIcon;
      });
    }
  }

  obtainDirectionAndDrawRoute(sourceLocationLatLng,
      destinationLocationLatLng) async //sourceLocationLatLng là vị trí nguồn nơi tài xế đứng và destinationLocationLatLng tọa độ vị trí đích
  {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => LoadingDialog(
              messageText: 'Please wait...',
            ));
    var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
        sourceLocationLatLng, destinationLocationLatLng);

    Navigator.pop(context);

    ///giải mã polyline và chuyển đổi thành danh sách các tọa độ (LatLng) để vẽ tuyến đường trên bản đồ
    PolylinePoints pointsPolyline =
        PolylinePoints(); //Tạo một instance khác của PolylinePoints để xử lý dữ liệu polyline
    List<PointLatLng> latLngPoints =
        pointsPolyline.decodePolyline(tripDetailsInfo!.encodedPoints!);

    coordinatesPolylineLatLngList
        .clear(); //Xóa mọi dữ liệu cũ trong danh sách coordinatesPolylineLatLngList, để đảm bảo danh sách chỉ chứa dữ liệu mới của tuyến đường.

    //kểm tra và chuyển đổi dữ liệu
    if (latLngPoints.isNotEmpty) {
      for (var pointLatLng in latLngPoints) {
        coordinatesPolylineLatLngList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    //vẽ polyline (tuyến đường) trên bản đồ
    polyLinesSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("routeID"),
          color: Colors.amber,
          points: coordinatesPolylineLatLngList,
          jointType: JointType.round,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polyLinesSet.add(polyline);
    });

    //fit the polyline on google map bằng cách tính toán LatLngBounds( vùng giới hạn) dựa trên tọa độ nguồn và đích,
    // sau đó điều chỉnh camera trên bản đồ.
    LatLngBounds boundsLatLng; //định nghĩa vùng giới hạn trên bản đồ

    if (sourceLocationLatLng.latitude > destinationLocationLatLng.latitude &&
        sourceLocationLatLng.longitude > destinationLocationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLocationLatLng,
        northeast: sourceLocationLatLng,
      );
    } else if (sourceLocationLatLng.longitude >
        destinationLocationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
            sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
        northeast: LatLng(
            destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
      );
    } else if (sourceLocationLatLng.latitude >
        destinationLocationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
            destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
        northeast: LatLng(
            sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: sourceLocationLatLng,
        northeast: destinationLocationLatLng,
      );
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    //add marker
    Marker sourceMarker = Marker(
      markerId: const MarkerId('sourceID'),
      position: sourceLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      position: destinationLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });

    //add circle
    Circle sourceCircle = Circle(
      circleId: const CircleId('sourceCircleID'),
      strokeColor: Colors.orange,
      strokeWidth: 4,
      radius: 14,
      center: sourceLocationLatLng,
      fillColor: Colors.green,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationCircleID'),
      strokeColor: Colors.green,
      strokeWidth: 4,
      radius: 14,
      center: destinationLocationLatLng,
      fillColor: Colors.orange,
    );

    setState(() {
      circlesSet.add(sourceCircle);
      circlesSet.add(destinationCircle);
    });
  }

  getLiveLocationUpdatesOfDriver() {
    LatLng lastPositionLatLng = const LatLng(0, 0);

    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position positionDriver) {
      driverCurrentPosition = positionDriver;

      LatLng driverCurrentPositionLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      Marker carMarker = Marker(
        markerId: const MarkerId("carMarkerID"),
        position: driverCurrentPositionLatLng,
        icon: carMarkerIcon!,
        infoWindow: const InfoWindow(title: "Vị trí của tôi"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: driverCurrentPositionLatLng, zoom: 16);
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((element) => element.markerId.value == "carMarkerID");
        markersSet.add(carMarker);
      });

      lastPositionLatLng = driverCurrentPositionLatLng;

      //cập nhật thông tin chi tiết chuyến đi
      updateTripDetailsInformation();

      //cập nhật vị trí tài xế lên tripRequest
      Map updatedLocationOfDriver = {
        "latitude": driverCurrentPosition!.latitude,
        "longitude": driverCurrentPosition!.longitude,
      };
      FirebaseDatabase.instance
          .ref()
          .child("tripRequests")
          .child(widget.newTripDetailsInfo!.tripID!)
          .child("driverLocation")
          .set(updatedLocationOfDriver);
    });
  }

  updateTripDetailsInformation() async {
    if (!directionRequested) {
      directionRequested = true;

      if (driverCurrentPosition == null) {
        return;
      }

      var driverLocationLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      LatLng dropOffDestinationLocationLatLng;
      if (statusOfTrip == "accepted") {
        //TH1: từ vị trí tài xế đến vị trí đón khách
        dropOffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.pickUpLatLng!;
      } else {
        //TH2: tư vị trí đón khách đến vị trí trả khách
        dropOffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.dropOffLatLng!;
      }

      var directionDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          driverLocationLatLng, dropOffDestinationLocationLatLng);

      if (directionDetailsInfo != null) {
        directionRequested = false;

        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  ///Kết thúc chuến đi
  endTripNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: "Vui lòng đợi..."),
    );

    var driverCurrentLocationLatLng = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    var directionDetailsEndTripInfo = await CommonMethods.getDirectionDetailsFromAPI(
      widget.newTripDetailsInfo!.dropOffLatLng!, // Điểm trả
      driverCurrentLocationLatLng, // Điểm đón
    );
    Navigator.pop(context);

    try {
      // Kiểm tra và lấy loại xe từ Firebase
      final vehicleTypeSnapshot = await FirebaseDatabase.instance
          .ref()
          .child('tripRequests')
          .child(widget.newTripDetailsInfo!.tripID!)
          .child('vehicleType')
          .get();

      if (vehicleTypeSnapshot.value != null) {
        String vehicleType = vehicleTypeSnapshot.value.toString();
        print("Vehicle Type: $vehicleType");

        // Tính giá theo loại xe
        double fareAmount;
        if (vehicleType == "taxi") {
          fareAmount = double.parse(cMethods.calculateFareAmount(directionDetailsEndTripInfo!));
        } else {
          fareAmount = double.parse(cMethods.calculateTruckFareAmount(directionDetailsEndTripInfo!));
        }

        // Cập nhật vào Firebase
        await FirebaseDatabase.instance
            .ref()
            .child("tripRequests")
            .child(widget.newTripDetailsInfo!.tripID!)
            .child("fareAmount")
            .set(fareAmount.toStringAsFixed(2));

        await FirebaseDatabase.instance
            .ref()
            .child("tripRequests")
            .child(widget.newTripDetailsInfo!.tripID!)
            .child("status")
            .set("ended");

        // Tiến hành các thao tác khác như đóng các đối tượng và lưu thu nhập
        positionStreamNewTripPage!.cancel();
        displayPaymentDialog(fareAmount.toStringAsFixed(2));
        saveFareAmountToDriverTotalEarnings(fareAmount.toStringAsFixed(2));
      } else {
        print("Vehicle type is missing or empty in Firebase.");
        // Nếu không có vehicleType, mặc định "taxi"
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  displayPaymentDialog(fareAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PaymentDialog(fareAmount: fareAmount),
    );
  }

  saveFareAmountToDriverTotalEarnings(String fareAmount) async {
    DatabaseReference driverEarningsRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");

    await driverEarningsRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double previousTotalEarnings =
            double.parse(snap.snapshot.value.toString());
        double fareAmountForTrip = double.parse(fareAmount);

        double newTotalEarnings = previousTotalEarnings + fareAmountForTrip;

        driverEarningsRef.set(newTotalEarnings);
      } else {
        driverEarningsRef.set(fareAmount);
      }
    });
  }

  //gán dữ liệu tài xế cho thông tin chuyến đi
  saveDriverDataToTripInfo() async {
    Map<String, dynamic> driverDataMap = {
      "status": "accepted", //cập nhaajt tình trạng chuyến đi
      "driverID": FirebaseAuth.instance.currentUser!.uid,
      "driverName": driverName,
      "driverPhone": driverPhone,
      "driverPhoto": driverPhoto,
      "carDetails": carColor + " - " + carModel + " - " + carNumber,

    };
    //cập nhật li vị trí của tài xế ( kinh độ và vĩ độ)
    Map<String, dynamic> driverCurrentLocation = {
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
    };

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .update(driverDataMap);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("driverLocation")
        .update(driverCurrentLocation);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveDriverDataToTripInfo();
  }

  @override
  Widget build(BuildContext context) {
    makeMarker();

    return Scaffold(
      body: Stack(
        children: [
          ///Google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: googleMapPaddingFromBottom),
            mapType: MapType.normal,
            //có thể thay thế loại bản đồ như bản đồ địa hình(hybird)...
            myLocationEnabled: true,
            markers: markersSet,
            circles: circlesSet,
            polylines: polyLinesSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) async {
              controllerGoogleMap = mapController;

              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                googleMapPaddingFromBottom = 262;
              });

              var driverCurrentLocationLatLng = LatLng(
                driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude,
              );

              var userPickUpLocationLatLng =
                  widget.newTripDetailsInfo!.pickUpLatLng;

              await obtainDirectionAndDrawRoute(
                  driverCurrentLocationLatLng, userPickUpLocationLatLng);

              getLiveLocationUpdatesOfDriver();
            },
          ),

          ///Google map

          ///chi tiết chuyến đi
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(17),
                    topLeft: Radius.circular(17)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 17,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: 256,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //trip duration
                    Center(
                      child: Text(
                        durationText + " - " + distanceText,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    //user name - call user icon btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //user name
                        Text(
                          widget.newTripDetailsInfo!.userName!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        //call user icon btn (online call)
                        GestureDetector(
                          onTap: ()
                          {
                            launchUrl(
                              Uri.parse(
                                  "tel://${widget.newTripDetailsInfo!.userPhone.toString()}"
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.phone_android_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    //pickup icon and location
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/initial.png",
                          height: 16,
                          width: 16,
                        ),
                        Expanded(
                          child: Text(
                            widget.newTripDetailsInfo!.pickupAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    //dropoff icon and location
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/final.png",
                          height: 16,
                          width: 16,
                        ),
                        Expanded(
                          child: Text(
                            widget.newTripDetailsInfo!.dropOffAddress
                                .toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          //arrived button
                          if (statusOfTrip == "accepted") {
                            setState(() {
                              buttonTitleText = "BẮT ĐẦU CHUYẾN ĐI";
                              buttonColor = Colors.green;
                            });

                            statusOfTrip = "arrived";

                            FirebaseDatabase.instance
                                .ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailsInfo!.tripID!)
                                .child("status")
                                .set("arrived");

                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) =>
                                    LoadingDialog(
                                      messageText: 'Please wait...',
                                    ));

                            await obtainDirectionAndDrawRoute(
                              widget.newTripDetailsInfo!.pickUpLatLng,
                              widget.newTripDetailsInfo!.dropOffLatLng,
                            );

                            Navigator.pop(context);
                          }
                          //start trip button
                          else if (statusOfTrip == "arrived") {
                            setState(() {
                              buttonTitleText = "KẾT THÚC CHUYẾN ĐI";
                              buttonColor = Colors.amber;
                            });

                            statusOfTrip = "ontrip";

                            FirebaseDatabase.instance
                                .ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailsInfo!.tripID!)
                                .child("status")
                                .set("ontrip");
                          }
                          //end trip button
                          else if (statusOfTrip == "ontrip") {
                            //end the trip
                            endTripNow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        child: Text(
                          buttonTitleText,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
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
