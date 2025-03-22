import 'package:drivers_app/themes/style1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class TripsHistoryPage extends StatefulWidget
{
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}



class _TripsHistoryPageState extends State<TripsHistoryPage>
{
  final completedTripRequestsOfCurrentDriver = FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chuyến đi đã hoàn thành của tôi',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ),
      body: StreamBuilder(
        stream: completedTripRequestsOfCurrentDriver.onValue,
        builder: (BuildContext context, snapshotData)
        {
          if(snapshotData.hasError)
          {
            return const Center(
              child: Text(
                "Đã xảy ra lỗi.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if(!(snapshotData.hasData))
          {
            return const Center(
              child: Text(
                "Không tìm thấy hồ sơ.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips.forEach((key, value) => tripsList.add({"key": key, ...value}));

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: ((context, index) {
              if (tripsList[index]["status"] != null &&
                  tripsList[index]["status"] == "ended" &&
                  tripsList[index]["driverID"] ==
                      FirebaseAuth.instance.currentUser!.uid) {
                // Xử lý timestamp để hiển thị ngày giờ
                DateTime tripDate;
                try {
                  String timestamp = tripsList[index]["publishDateTime"];
                  String sanitizedTimestamp = timestamp.split('.').first; // Loại bỏ microseconds
                  tripDate = DateTime.parse(sanitizedTimestamp);
                } catch (e) {
                  tripDate = DateTime.now(); // Giá trị mặc định nếu có lỗi
                }

                // Định dạng ngày giờ
                String formattedDate =
                DateFormat('dd MMMM yyyy, HH:mm').format(tripDate);


                return Card(
                  color: Colors.white12,
                  elevation: 10,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ngày giờ chuyến đi
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),

                        const SizedBox(height: 10),

                        // Pickup - Fare amount
                        Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.yellowAccent),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                tripsList[index]["pickUpAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              tripsList[index]["fareAmount"].toString() + " "+ "VNĐ",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Dropoff
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: redColor),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                tripsList[index]["dropOffAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}
