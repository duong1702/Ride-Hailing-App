import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';

String userName = "";
String userPhone = "";

String goongMapKey = "ap86GtclktuYEFP5AMouG6I2yavEcS3jydgVCuvn";
//String googleMapKey = "AIzaSyDbdOTifQB93vXaSyHIIPRIi_KV8r6lWec";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(8.179, 109.464),
  zoom: 14.4746,
);

StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

int driverTripRequestTimeout = 20;

final AudioPlayer audioPlayer = AudioPlayer();

Position? driverCurrentPosition;

//khởi tạo các biến về thông tin tài xế
String driverName = "";
String driverPhone = "";
String driverPhoto = "";
String carColor = "";
String carModel = "";
String carNumber = "";
