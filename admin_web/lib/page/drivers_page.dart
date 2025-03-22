import 'package:admin_web/widgets/drivers_data_list.dart';
import 'package:flutter/material.dart';

class DriversPage extends StatefulWidget {
  static const String id = "\webPageDrivers";

  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  TextEditingController _searchController = TextEditingController();
  String selectedFilter = "All"; // Mặc định là "Tất cả"
  //List<String> filterOptions = ["All", "Chặn", "Bỏ chặn"];

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
      appBar: AppBar(
        title: const Text(
          'Quản lý Tài Xế',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Thanh tìm kiếm tài xế
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Tìm kiếm tài xế",
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

              const SizedBox(height: 20),

              // Tiêu đề của các cột trong bảng

              // Hiển thị danh sách tài xế
              DriversDataList(
                searchQuery: _searchController.text,
                filterStatus: selectedFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
