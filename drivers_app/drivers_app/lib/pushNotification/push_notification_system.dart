//import 'package:drivers_app/global/global_var.dart';
import 'package:drivers_app/models/trip_details.dart';
import 'package:drivers_app/widgets/notification_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart'; // Thư viện mới
import '../widgets/loading.dart';

class PushNotificationSystem {
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;
  final AudioPlayer audioPlayer = AudioPlayer(); // Tạo một instance của AudioPlayer

  Future<String?> generateDeviceRegistrationToken() async {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();

    DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");

    referenceOnlineDriver.set(deviceRecognitionToken);

    firebaseCloudMessaging.subscribeToTopic("drivers");
    firebaseCloudMessaging.subscribeToTopic("users");
    return null;
  }

  startListeningForNewNotification(BuildContext context) async {
    /// 1. Khi ứng dụng đóng
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });

    /// 2. Khi ứng dụng đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });

    /// 3. Khi ứng dụng chạy nền
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  retrieveTripRequestInfo(String tripID, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Nhận thông tin chi tiết..."),
    );

    DatabaseReference tripRequestsRef = FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);

    tripRequestsRef.once().then((dataSnapshot)
    {
      Navigator.pop(context);

      // Sử dụng just_audio để phát âm thanh
      try {
        audioPlayer.setAsset("assets/audio/alert_sound.mp3"); // Đặt tệp âm thanh
        audioPlayer.play(); // Phát âm thanh
      } catch (e) {
        print("Lỗi khi phát âm thanh: $e");
      }

      TripDetails tripDetailsInfo = TripDetails();
      double pickUpLat = double.parse((dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
      double pickUpLng = double.parse((dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);
      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

      tripDetailsInfo.pickupAddress = (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

      double dropOffLat = double.parse((dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
      double dropOffLng = double.parse((dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);
      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      tripDetailsInfo.dropOffAddress = (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

      tripDetailsInfo.userName = (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailsInfo.userPhone = (dataSnapshot.snapshot.value! as Map)["userPhone"];

      tripDetailsInfo.tripID = tripID;

      showDialog(
        context: context,
        builder: (BuildContext context) => NotificationDialog(tripDetailsInfo: tripDetailsInfo),
      );
    });
  }
}
