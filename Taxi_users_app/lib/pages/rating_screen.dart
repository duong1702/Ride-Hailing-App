import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingScreen extends StatefulWidget {
  final String tripID;
  final String driverID;

  const RatingScreen({Key? key, required this.tripID, required this.driverID})
      : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _submitRating() async {
    final DatabaseReference driverRatingRef =
    FirebaseDatabase.instance.ref('driverRatings/${widget.driverID}');

    // Lưu đánh giá
    await driverRatingRef.child("ratings").push().set(_rating);

    // Lưu ý kiến
    if (_feedbackController.text.isNotEmpty) {
      await driverRatingRef.child("feedbacks").push().set(
          _feedbackController.text.trim());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
    );

    Navigator.pop(context); // Quay lại màn hình trước
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh giá tài xế"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Vui lòng đánh giá chuyến đi này",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Widget đánh giá sao
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) =>
              const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Ô nhập ý kiến
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: "Ý kiến đóng góp (tuỳ chọn)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Nút gửi đánh giá
            ElevatedButton(
              onPressed: _rating > 0 ? _submitRating : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
              ),
              child: const Text(
                "Gửi đánh giá",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
