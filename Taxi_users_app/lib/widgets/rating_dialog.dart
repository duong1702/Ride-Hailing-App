import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:intl/intl.dart'; // Để sử dụng DateFormat

class RatingDialog extends StatefulWidget {
  final String tripID;
  final String driverID;
  final String userID; // Thêm userID để lấy tên người dùng

  const RatingDialog({Key? key, required this.tripID, required this.driverID, required this.userID}) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    if (_rating == 0) {
      // Nếu chưa chọn điểm đánh giá, yêu cầu người dùng chọn đánh giá
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn xếp hạng!")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true; // Đang gửi đánh giá
    });

    final DatabaseReference driverRatingRef = FirebaseDatabase.instance.ref('driverRatings/${widget.driverID}');

    // Lưu đánh giá vào Firebase
    final newRatingRef = driverRatingRef.child('ratings').push();
    final timestamp = DateTime.now().millisecondsSinceEpoch; // Tạo timestamp

    await newRatingRef.set({
      'rating': _rating,
      'timestamp': timestamp, // Lưu thời gian dưới dạng timestamp
    });

    // Lưu phản hồi (nếu có)
    if (_feedbackController.text.isNotEmpty) {
      final newFeedbackRef = driverRatingRef.child('feedbacks').push();
      await newFeedbackRef.set({
        'feedback': _feedbackController.text.trim(),
        'timestamp': timestamp, // Lưu thời gian phản hồi
        'userName': await _getUserName(), // Lấy tên người dùng từ Firebase
      });
    }

    // Cập nhật lại điểm trung bình và tổng số đánh giá cho tài xế
    await _updateDriverAverageRating();

    Navigator.pop(context, true); // Đóng hộp thoại và trả về kết quả
  }

  Future<String> _getUserName() async {
    // Lấy tên người dùng từ bảng `users`
    final userSnapshot = await FirebaseDatabase.instance.ref('users/${widget.userID}').get();
    if (userSnapshot.exists) {
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      return userData['name'] ?? 'Anonymous'; // Trả về tên người dùng hoặc 'Anonymous' nếu không có tên
    }
    return 'Anonymous';
  }

  Future<void> _updateDriverAverageRating() async {
    // Lấy thông tin tài xế từ Firebase
    final driverRef = FirebaseDatabase.instance.ref('drivers/${widget.driverID}');
    final driverSnapshot = await driverRef.get();

    if (driverSnapshot.exists) {
      final driverData = Map<String, dynamic>.from(driverSnapshot.value as Map);

      final double currentAverage = (driverData['averageRating'] ?? 0.0).toDouble();
      final int totalRatings = (driverData['totalRatings'] ?? 0).toInt();

      final newAverage = ((currentAverage * totalRatings) + _rating) / (totalRatings + 1);
      final newTotalRatings = totalRatings + 1;

      // Cập nhật điểm trung bình và tổng số đánh giá của tài xế
      await driverRef.update({
        'averageRating': newAverage,
        'totalRatings': newTotalRatings,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Đánh giá tài xế của bạn"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _feedbackController,
            decoration: const InputDecoration(labelText: "Để lại phản hồi (tùy chọn)"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Đóng hộp thoại mà không gửi đánh giá
          child: const Text("Trở về"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating, // Disable khi đang gửi
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Gửi"),
        ),
      ],
    );
  }
}
