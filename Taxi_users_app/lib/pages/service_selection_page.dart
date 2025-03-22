import 'package:flutter/material.dart';

class ServiceSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn dịch vụ"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/taxi_booking');
              },
              child: Text("Đặt xe Taxi"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/truck_booking');
              },
              child: Text("Đặt xe Tải"),
            ),
          ],
        ),
      ),
    );
  }
}
