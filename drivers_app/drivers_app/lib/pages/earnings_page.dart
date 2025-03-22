import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String totalEarnings = "0"; // Tổng thu nhập
  Map<String, double> earningsByDate = {}; // Thu nhập theo ngày
  bool isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    fetchEarningsData();
  }

  // Hàm lấy dữ liệu thu nhập từ Firebase
  Future<void> fetchEarningsData() async {
    try {
      String driverId = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference tripRequestsRef = FirebaseDatabase.instance.ref().child("tripRequests");

      final snapshot = await tripRequestsRef.once();
      if (snapshot.snapshot.value != null) {
        Map data = snapshot.snapshot.value as Map;

        double total = 0.0;
        Map<String, double> tempEarningsByDate = {};

        data.forEach((key, value) {
          if (value["driverID"] == driverId && value["status"] == "ended") {
            double fare = double.tryParse(value["fareAmount"].toString()) ?? 0.0;
            String date = value["publishDateTime"]?.split(" ")?.first ?? "Unknown";

            // Tính tổng thu nhập
            total += fare;

            // Tính thu nhập theo ngày
            tempEarningsByDate[date] = (tempEarningsByDate[date] ?? 0.0) + fare;
          }
        });

        setState(() {
          totalEarnings = total.toStringAsFixed(1);
          earningsByDate = tempEarningsByDate;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching earnings data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Xây dựng biểu đồ thu nhập theo ngày
  Widget buildEarningsChart(Map<String, double> earningsByDate) {
    return SfCartesianChart(
      title: ChartTitle(
        text: "Thu nhập theo ngày",
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: "Ngày",
          textStyle: const TextStyle(fontSize: 12),
        ),
        labelRotation: -45,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: "Thu nhập (VNĐ)",
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<MapEntry<String, double>, String>(
          dataSource: earningsByDate.entries.toList(),
          xValueMapper: (MapEntry<String, double> data, _) => data.key,
          yValueMapper: (MapEntry<String, double> data, _) => data.value,
          name: "Thu nhập",
          color: Colors.blueAccent,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thu nhập tài xế"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị tổng thu nhập
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                color: Colors.indigo,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Image.asset("assets/images/totalearnings.png", width: 120),
                      const SizedBox(height: 10),
                      const Text(
                        "Tổng Thu Nhập:",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "$totalEarnings VNĐ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hiển thị biểu đồ thu nhập theo ngày
            earningsByDate.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 400,
                child: buildEarningsChart(earningsByDate),
              ),
            )
                : const Center(child: Text("Không có dữ liệu thu nhập theo ngày")),
          ],
        ),
      ),
    );
  }
}
