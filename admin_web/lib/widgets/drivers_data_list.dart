import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/methods/common_methods.dart';

class DriversDataList extends StatefulWidget {
  final String searchQuery;
  final String filterStatus;

  const DriversDataList({super.key, required this.searchQuery, required this.filterStatus});

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList> {
  final driversRecordsFromDatabase = FirebaseDatabase.instance.ref().child("drivers");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Đã xảy ra lỗi. Thử lại sau.",
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

        // Lọc dữ liệu theo từ khóa tìm kiếm và trạng thái (filterStatus)
        List filteredItemsList = itemsList.where((item) {
          final searchMatch = item["name"].toString().toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
              item["id"].toString().contains(widget.searchQuery);
          final statusMatch = widget.filterStatus == 'All' || item["blockStatus"] == widget.filterStatus;
          return searchMatch && statusMatch;
        }).toList();

        // Cập nhật lại danh sách trong DataTable
        List<DataRow> rows = filteredItemsList.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item["id"].toString())),
              DataCell(Image.network(
                item["photo"].toString(),
                width: 50,
                height: 50,
              )),
              DataCell(Text(item["name"].toString())),
              DataCell(Text(
                "${item["car_details"]["carColor"]}_${item["car_details"]["carModel"]} _ ${item["car_details"]["carNumber"]}",
              )),
              DataCell(Text(item["phone"].toString())),
              DataCell(Text(item["vehicleType"].toString())),
              DataCell(Text(item["earnings"] != null ? "${item["earnings"]} VNĐ" : "0 VNĐ")),
              DataCell(
                item["blockStatus"] == "no"
                    ? ElevatedButton(
                  onPressed: () async {
                    await FirebaseDatabase.instance
                        .ref()
                        .child("drivers")
                        .child(item["id"])
                        .update({"blockStatus": "yes"});
                  },
                  child: const Text("Chặn Tài Xế", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
                    : ElevatedButton(
                  onPressed: () async {
                    await FirebaseDatabase.instance
                        .ref()
                        .child("drivers")
                        .child(item["id"])
                        .update({"blockStatus": "no"});
                  },
                  child: const Text("Bỏ chặn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.pink),
            columnSpacing: 42, // Tăng khoảng cách giữa các
            dataRowHeight: 60, // Điều chỉnh chiều cao của dòng dữ liệu
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Đặt màu viền cho tất cả các cột
                width: 1.0, // Đặt độ rộng viền
              ),
            ),
            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            columns: const [
              DataColumn(label: Text("Driver ID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,))),
              DataColumn(label: Text("Hình ảnh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Tên", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Chi tiết xe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Điện thoại", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Loại xe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Thu nhập", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Trạng thái", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
            rows: rows,
          ),
        );
      },
    );
  }
}
