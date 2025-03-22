import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html; // Thêm thư viện dart:html
import '../methods/common_methods.dart';

class TripsDataList extends StatefulWidget {
  final String searchQuery;

  const TripsDataList({super.key, required this.searchQuery});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}

class _TripsDataListState extends State<TripsDataList> {
  final completedTripsRecordsFromDatabase = FirebaseDatabase.instance.ref().child("tripRequests");
  CommonMethods cMethods = CommonMethods();
  List<dynamic> filteredItemsList = []; // Danh sách chuyến đi đã lọc

  // Mở Google Maps
  launchGoogleMapFromSourceToDestination(pickUpLat, pickUpLng, dropOffLat, dropOffLng) async {
    String directionAPIUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunchUrl(Uri.parse(directionAPIUrl))) {
      await launchUrl(Uri.parse(directionAPIUrl));
    } else {
      throw "Không thể tải bản đồ Google Maps";
    }
  }

  // Hàm xuất file Excel
  Future<void> exportToExcel() async {
    var excel = Excel.createExcel(); // Tạo file Excel mới
    Sheet sheet = excel['Danh sách chuyến đi']; // Tạo sheet "Danh sách chuyến đi"

    // Thêm tiêu đề cột
    sheet.appendRow([
      "ID Chuyến Đi",
      "Tên Người Dùng",
      "Tên Tài Xế",
      "Thông Tin Xe",
      "Ngày Giờ",
      "Giá Tiền"
    ]);

    // Thêm dữ liệu chuyến đi
    for (var trip in filteredItemsList) {
      sheet.appendRow([
        trip["tripID"]?.toString() ?? "Không rõ",
        trip["userName"]?.toString() ?? "Không rõ",
        trip["driverName"]?.toString() ?? "Không rõ",
        trip["carDetails"]?.toString() ?? "Không rõ",
        trip["publishDateTime"]?.toString() ?? "Không rõ",
        trip["fareAmount"]?.toString() ?? "0",
      ]);
    }

    // Tính tổng thu nhập
    double totalIncome = 0.0;
    for (var item in filteredItemsList) {
      if (item["status"] == "ended") {
        totalIncome += double.tryParse(item["fareAmount"].toString()) ?? 0.0;
      }
    }

    // Thêm tổng thu nhập vào cuối file Excel
    sheet.appendRow([]);
    sheet.appendRow(["Tổng Thu Nhập:", "", "", "", "", "${totalIncome.toStringAsFixed(1)} VNĐ"]);

    // Tạo file Excel và tải xuống trên trình duyệt
    final List<int>? bytes = excel.encode();
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể tạo file Excel")),
      );
      return;
    }

    final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = "TripsData.xlsx"
      ..click();

    html.Url.revokeObjectUrl(url); // Giải phóng tài nguyên

    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Xuất Excel thành công!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: completedTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Có lỗi xảy ra. Vui lòng thử lại sau.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.pink,
              ),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...value});
        });

        // Lọc dữ liệu chỉ theo tên tài xế (driverName)
        filteredItemsList = itemsList.where((item) {
          final searchMatch = item["driverName"].toString().toLowerCase().contains(widget.searchQuery.toLowerCase());
          return searchMatch;
        }).toList();

        // Tính tổng thu nhập của tài xế
        double totalIncome = 0.0;
        for (var item in filteredItemsList) {
          if (item["status"] == "ended") {
            totalIncome += double.tryParse(item["fareAmount"].toString()) ?? 0.0;
          }
        }

        return Column(
          children: [

            // Hiển thị danh sách chuyến đi đã lọc
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredItemsList.length,
              itemBuilder: (context, index) {
                if (filteredItemsList[index]["status"] != null && filteredItemsList[index]["status"] == "ended") {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cMethods.data(
                        2,
                        Text(filteredItemsList[index]["tripID"].toString()),
                      ),
                      cMethods.data(
                        1,
                        Text(filteredItemsList[index]["userName"].toString()),
                      ),
                      cMethods.data(
                        1,
                        Text(filteredItemsList[index]["driverName"].toString()),
                      ),
                      cMethods.data(
                        1,
                        Text(filteredItemsList[index]["carDetails"].toString()),
                      ),
                      cMethods.data(
                        1,
                        Text(filteredItemsList[index]["publishDateTime"].toString()),
                      ),
                      cMethods.data(
                        1,
                        Text(filteredItemsList[index]["fareAmount"].toString() + " VNĐ"),
                      ),
                      cMethods.data(
                        1,
                        ElevatedButton(
                          onPressed: ()
                          {
                            String pickUpLat = itemsList[index]["pickUpLatLng"]["latitude"];
                            String pickUpLng = itemsList[index]["pickUpLatLng"]["longitude"];

                            String dropOffLat = itemsList[index]["dropOffLatLng"]["latitude"];
                            String dropOffLng = itemsList[index]["dropOffLatLng"]["longitude"];

                            launchGoogleMapFromSourceToDestination(
                              pickUpLat,
                              pickUpLng,
                              dropOffLat,
                              dropOffLng,
                            );
                          },
                          child: const Text(
                            "Xem thêm",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),

            // Hiển thị tổng thu nhập
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tổng thu nhập: ${totalIncome.toStringAsFixed(1)} VNĐ", // Làm tròn đến 1 chữ số
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // Nút xuất Excel
            ElevatedButton(
              onPressed: exportToExcel,
              child: const Text("Xuất Excel"),
            ),
          ],
        );
      },
    );
  }
}
