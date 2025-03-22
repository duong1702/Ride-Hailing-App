import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_users_app/methods/common_methods.dart';
import 'package:taxi_users_app/models/prediction_model.dart';
import 'package:taxi_users_app/widgets/prediction_place_ui.dart';

import '../appInfo/app_info.dart';
import '../themes/style1.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<PredictionModel> dropOffPredictionsPlacesList = [];

  Timer? _debounce;

  /// Places API - Place AutoComplete
  searchLocation(String locationName) async {
    if (locationName.length >= 4) { // Kiểm tra đủ số ký tự trước khi gọi API
      // URL của Goong Places API
      String goongMapKey = "ap86GtclktuYEFP5AMouG6I2yavEcS3jydgVCuvn";
      String apiPlacesUrl = "https://rsapi.goong.io/Place/AutoComplete?api_key=$goongMapKey&input=$locationName";

      var responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(apiPlacesUrl);

      if (responseFromPlacesAPI == "error") {
        return;
      }

      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionResultInJson = responseFromPlacesAPI["predictions"];
        var predictionsList = (predictionResultInJson as List)
            .map((eachPlacePrediction) => PredictionModel.fromJson(eachPlacePrediction))
            .toList();

        setState(() {
          dropOffPredictionsPlacesList = predictionsList;
        });
      }
    } else {
      setState(() {
        dropOffPredictionsPlacesList = [];
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Hủy debounce khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.humanReadableAddress ?? "";
    pickUpTextEditingController.text = userAddress;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 18),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),

                      // Icon button - title
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back, color: Colors.black54),
                          ),
                          const Center(
                            child: Text(
                              "Tìm kiếm địa điểm",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup text field
                          Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.black),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextField(
                                    controller: pickUpTextEditingController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      hintText: "Điểm đón",
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 9,
                                        horizontal: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.grey),
                          ),

                          // Trường trả khách
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: redColor),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextField(
                                    controller: destinationTextEditingController,
                                    style: const TextStyle(color: Colors.black),
                                    onChanged: (inputText) {
                                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                                      _debounce = Timer(const Duration(seconds: 2), () {
                                        searchLocation(inputText);
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Điểm trả",
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none,
                                      ),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 9,
                                        horizontal: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Hiển thị kết quả dự đoán cho địa điểm đến
            (dropOffPredictionsPlacesList.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    child: PredictionPlaceUI(
                      predictedPlaceData: dropOffPredictionsPlacesList[index],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 2),
                itemCount: dropOffPredictionsPlacesList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
