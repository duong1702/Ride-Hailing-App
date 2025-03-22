// ignore_for_file: unused_import, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  String messageText;

  LoadingDialog({
    super.key,
    required this.messageText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.black87,
        child: Container(
            margin: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(5),
            ), //decoration là thuộc tính tùy chỉnh giao diện các widgets
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    messageText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )));
  }
}
