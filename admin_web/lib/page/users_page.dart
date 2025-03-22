import 'package:admin_web/widgets/users_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class UsersPage extends StatefulWidget
{
  static const String id = "\webPageUsers";

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  TextEditingController _searchController = TextEditingController();
  String selectedFilter = "All";

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
                  "QUẢN LÝ NGƯỜI DÙNG",
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
                    labelText: "Tìm kiếm người dùng",
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
                  cMethods.header(2, "ID NGƯỜI DÙNG"),
                  cMethods.header(1, "TÊN"),
                  cMethods.header(1, "EMAIL"),
                  cMethods.header(1, "SỐ ĐIỆN THOẠI"),
                  cMethods.header(1, "TRẠNG THÁI"),
                ],
              ),
              //display data

              UsersDataList(
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
