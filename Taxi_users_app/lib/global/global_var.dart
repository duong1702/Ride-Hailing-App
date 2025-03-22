import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;

String goongMapKey = "ap86GtclktuYEFP5AMouG6I2yavEcS3jydgVCuvn";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(8.179, 109.464),
  zoom: 14.4746,
);

String pageName = "";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();