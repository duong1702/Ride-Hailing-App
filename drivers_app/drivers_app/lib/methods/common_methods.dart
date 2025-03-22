// ignore_for_file: unrelated_type_equality_checks
import 'dart:convert';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/direction_details.dart';

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar(
          "Your Internet is not Available. Check your connection. Try Again.",
          context);
    }
  }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //tắt cập nhật vị trí của trang chủ và chuyển sang trang chuyến đi mới
  turnOffLocationUpdatesForHomePage()
  {
    positionStreamHomePage!.pause();

    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdatesForHomePage()
  {
    positionStreamHomePage!.resume();

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
  }

  ///Gửi yêu cau tới API (dùng API geocoding của goong)
  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  /// Goong Directions API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async
  {
    String urlDirectionsAPI = "https://rsapi.goong.io/Direction?origin=${source.latitude},${source.longitude}&destination=${destination.latitude},${destination.longitude}&vehicle=car&api_key=$goongMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if(responseFromDirectionsAPI == "error")
    {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints = responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  String calculateFareAmount(DirectionDetails directionDetails) {
    const double distancePerKmAmount = 6.000; // Đơn giá mỗi km
    const double durationPerMinuteAmount = 5.000; // Đơn giá mỗi phút
    const double baseFareAmount = 8.000; // Phí cơ bản
    const double minimumFare = 10.000; // Phí tối thiểu
    const double longDistanceDiscount = 0.8; // Giảm giá quãng đường dài
    const double peakTimeMultiplier = 1.5;
    // Tăng giá giờ cao điểm



    if (directionDetails.distanceValueDigits == null || directionDetails.durationValueDigits == null) {
      throw ArgumentError("Direction details cannot be null.");
    }

    // Tính phí di chuyển dựa trên khoảng cách
    double totalDistanceTravelFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    print("Distance fare: $totalDistanceTravelFareAmount");

    // Giảm giá cho quãng đường dài trên 20 km
    if (directionDetails.distanceValueDigits! > 20000) {
      totalDistanceTravelFareAmount *= longDistanceDiscount;
    }

    // Tính phí dựa trên thời gian
    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 3600) * durationPerMinuteAmount;

    // Phí tối thiểu cho chuyến đi ngắn dưới 1 km
    if (directionDetails.distanceValueDigits! < 1000) {
      totalDistanceTravelFareAmount = minimumFare;
    }

    // Tính tổng phí
    double overAllTotalFareAmount = baseFareAmount +
        totalDistanceTravelFareAmount +
        totalDurationSpendFareAmount;

    // Lấy thời gian hiện tại để kiểm tra giờ cao điểm
    DateTime currentTime = DateTime.now();
    int currentHour = currentTime.hour;

    // Kiểm tra giờ cao điểm
    bool isPeakTime = (currentHour >= 7 && currentHour < 9) ||
        (currentHour >= 11 && currentHour < 14) ||
        (currentHour >= 17 && currentHour < 19);

    // Nếu là giờ cao điểm, tăng giá cước
    if (isPeakTime) {
      overAllTotalFareAmount *= peakTimeMultiplier;
    }

    // Trả về kết quả
    return overAllTotalFareAmount.toStringAsFixed(1);
  }



  String calculateTruckFareAmount(DirectionDetails directionDetails) {
    // Đơn giá cơ bản và phí cho xe tải nhỏ
    double distancePerKmAmount = 8.000; // Giá mỗi km cho xe tải nhỏ
    double baseFareAmount = 12.000; // Phí cơ bản cho xe tải nhỏ
    double fuelCostPerKm = 2.500; // Chi phí nhiên liệu mỗi km cho xe tải nhỏ
    double cargoWeight = 300; // Trọng lượng cố định là 500 kg

    // Phụ phí hàng hóa
    double cargoFee = cargoWeight * 0.5; // Mỗi kg hàng hóa tăng thêm 0.5 VND

    print("Input distance (meters): ${directionDetails.distanceValueDigits}");
    print("Input duration (seconds): ${directionDetails.durationValueDigits}");
    // Tính phí di chuyển dựa trên khoảng cách
    double totalDistanceTravelFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;

    print("Step 1: Distance fare = $totalDistanceTravelFareAmount");
    // Giảm giá cho quãng đường dài trên 50 km
    if (directionDetails.distanceValueDigits! > 50000) { // 50 km = 50000 mét
      totalDistanceTravelFareAmount *= 0.85; // Giảm 15%
      print("Step 1a: Long-distance discount applied. New distance fare = $totalDistanceTravelFareAmount");
    }

    // Tính chi phí nhiên liệu
    double totalFuelCost = (directionDetails.distanceValueDigits! / 1000) * fuelCostPerKm;
    print("Step 2: Fuel cost = $totalFuelCost");

    // Tính phí dựa trên thời gian di chuyển
    double durationPerMinuteAmount = 3.000; // Đơn giá mỗi phút
    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;
    print("Step 3: Duration fare = $totalDurationSpendFareAmount");

    // Tính tổng phí
    double overallTotalFareAmount =
        baseFareAmount + totalDistanceTravelFareAmount + totalDurationSpendFareAmount + cargoFee + totalFuelCost;

    print("Step 4: Total fare before peak time = $overallTotalFareAmount");
    // Kiểm tra giờ cao điểm
    DateTime currentTime = DateTime.now();
    int currentHour = currentTime.hour;
    bool isPeakTime = (currentHour >= 7 && currentHour <= 8) ||
        (currentHour >= 11 && currentHour <= 13) ||
        (currentHour >= 17 && currentHour <= 18);

    print("Current time: $currentTime, Peak time: $isPeakTime");
    // Nếu là giờ cao điểm, tăng 30%
    if (isPeakTime) {
      overallTotalFareAmount *= 1.3;
      print("Step 5: Peak time surcharge applied. Total fare = $overallTotalFareAmount");
    }

    // Trả về giá trị đã làm tròn 2 chữ số thập phân
    return overallTotalFareAmount.toStringAsFixed(2);

  }

}