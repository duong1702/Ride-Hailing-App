import 'package:admin_web/methods/common_methods.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UsersDataList extends StatefulWidget {
  final String searchQuery;
  final String filterStatus;

  const UsersDataList({super.key, required this.searchQuery, required this.filterStatus});

  @override
  State<UsersDataList> createState() => _UsersDataListState();
}

class _UsersDataListState extends State<UsersDataList> {
  final usersRecordsFromDatabase = FirebaseDatabase.instance.ref().child("users");
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Đã xảy ra lỗi. Thử sau",
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

        if (!snapshotData.hasData || snapshotData.data!.snapshot.value == null) {
          return const Center(
            child: Text(
              "Không có dữ liệu để hiển thị",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          );
        }

        // Chuyển dữ liệu từ snapshot
        final dataValue = snapshotData.data!.snapshot.value;
        if (dataValue is! Map) {
          return const Center(
            child: Text(
              "Dữ liệu không hợp lệ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          );
        }

        Map dataMap = Map<String, dynamic>.from(dataValue as Map);
        List<Map<String, dynamic>> itemsList = [];
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...Map<String, dynamic>.from(value)});
        });

        // Lọc dữ liệu theo từ khóa tìm kiếm và trạng thái
        List<Map<String, dynamic>> filteredItemsList = itemsList.where((item) {
          final searchMatch = item["name"]
              .toString()
              .toLowerCase()
              .contains(widget.searchQuery.toLowerCase()) ||
              item["id"].toString().contains(widget.searchQuery);
          final statusMatch =
              widget.filterStatus == 'All' || item["blockStatus"] == widget.filterStatus;
          return searchMatch && statusMatch;
        }).toList();

        // Sử dụng filteredItemsList trong ListView.builder
        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredItemsList.length,
          itemBuilder: (context, index) {
            final item = filteredItemsList[index];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cMethods.data(
                  2,
                  Text(item["id"].toString()),
                ),
                cMethods.data(
                  1,
                  Text(item["name"].toString()),
                ),
                cMethods.data(
                  1,
                  Text(item["email"].toString()),
                ),
                cMethods.data(
                  1,
                  Text(item["phone"].toString()),
                ),
                cMethods.data(
                  1,
                  item["blockStatus"] == "no"
                      ? ElevatedButton(
                    onPressed: () async {
                      await usersRecordsFromDatabase
                          .child(item["id"])
                          .update({"blockStatus": "yes"});
                    },
                    child: const Text(
                      "Chặn",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () async {
                      await usersRecordsFromDatabase
                          .child(item["id"])
                          .update({"blockStatus": "no"});
                    },
                    child: const Text(
                      "Bỏ chặn",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
