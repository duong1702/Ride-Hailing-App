import 'package:admin_web/widgets/trips_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class TripsPage extends StatefulWidget
{
  static const String id = "\webPageTrips";

  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  TextEditingController _searchController = TextEditingController();
  CommonMethods cMethods = CommonMethods();


  @override
  void initState() {
    super.initState();

    // Thêm Listener để theo dõi sự thay đổi trong ô tìm kiếm
    _searchController.addListener(() {
      setState(() {
        // Khi có sự thay đổi trong ô tìm kiếm, giao diện sẽ được cập nhật
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "QUẢN LÝ CHUYẾN ĐI",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Tìm kiếm chuyến đi",
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {}); // Cập nhật giao diện khi xóa tìm kiếm
                      },
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  cMethods.header(2, "ID"),
                  cMethods.header(1, "TÊN NGƯỜI DÙNG"),
                  cMethods.header(1, "TÊN TÀI XẾ"),
                  cMethods.header(1, "THÔNG TIN XE"),
                  cMethods.header(1, "THỜI GIAN"),
                  cMethods.header(1, "GIÁ TIỀN"),
                  cMethods.header(1, "XEM CHI TIẾT"),
                ],
              ),
              //display data
              TripsDataList(
                searchQuery: _searchController.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
