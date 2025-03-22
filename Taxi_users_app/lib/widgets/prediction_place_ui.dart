// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_users_app/appInfo/app_info.dart';
import 'package:taxi_users_app/global/global_var.dart';
import 'package:taxi_users_app/methods/common_methods.dart';
import 'package:taxi_users_app/models/address_model.dart';
import 'package:taxi_users_app/models/prediction_model.dart';
import 'package:taxi_users_app/widgets/loading.dart';


class PredictionPlaceUI extends StatefulWidget
{
  PredictionModel? predictedPlaceData;

  PredictionPlaceUI({super.key, this.predictedPlaceData,});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI>
{
  ///Place details - Địa điểm chi tiết
  /// Lấy chi tiết địa điểm từ Goong Places API
  fetchClickedPlaceDetails(String placeID) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: "Đang lấy chi tiết..."),
    );

    // URL API của Goong Places
    String urlPlaceDetailsAPI = "https://rsapi.goong.io/Place/Detail?place_id=$placeID&api_key=$goongMapKey";

    var responseFromPlaceDetailsAPI = await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);

    Navigator.pop(context);

    if (responseFromPlaceDetailsAPI == "error") {
      return;
    }

    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      AddressModel dropOffLocation = AddressModel();

      dropOffLocation.placeName = responseFromPlaceDetailsAPI["result"]["name"];
      dropOffLocation.latitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      dropOffLocation.longitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];
      dropOffLocation.placeID = placeID;

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);

      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        fetchClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: SizedBox(
        child: Column(
          children: [

            const SizedBox(height: 10,),

            Row(
              children: [

                const Icon(
                  Icons.share_location,
                  color: Colors.grey,
                ),

                const SizedBox(width: 13,),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Text(
                        widget.predictedPlaceData!.description.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 3,),

                      Text(
                        widget.predictedPlaceData!.description.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10,),

          ],
        ),
      ),
    );
  }
}
