import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function onSearch;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Tìm kiếm",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            controller.clear();
            onSearch(); // Gọi hàm tìm kiếm khi xóa
          },
        ),
      ),
      onChanged: (text) {
        onSearch(); // Gọi hàm tìm kiếm mỗi khi thay đổi văn bản
      },
    );
  }
}
