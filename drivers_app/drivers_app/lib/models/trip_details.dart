import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails
{
  String? tripID;

  LatLng? pickUpLatLng;
  String? pickupAddress;

  LatLng? dropOffLatLng;
  String? dropOffAddress;
  String? truckType;
  String? userName;
  String? userPhone;
  String? vehicleType;
  double? cargoWeight;


  TripDetails({
    this.tripID,
    this.pickUpLatLng,
    this.pickupAddress,
    this.dropOffLatLng,
    this.dropOffAddress,
    this.userName,
    this.userPhone,
    this.vehicleType,
    this.cargoWeight,
    this.truckType,
  });
}