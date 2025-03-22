import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatelessWidget {
  static const String id = "\webDashboardPage";

  final Map<String, int> tripsByDriver;
  final Map<String, double> incomeByDriver;
  final Map<String, int> tripsByDate;
  final Map<String, double> incomeByDate;

  const Dashboard({
    super.key,
    required this.tripsByDriver,
    required this.incomeByDriver,
    required this.tripsByDate,
    required this.incomeByDate,
  });

  // Biểu đồ: Số chuyến đi theo tài xế
  Widget buildTripsByDriverChart(Map<String, int> tripsByDriver) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Số chuyến đi theo tài xế'),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<MapEntry<String, int>, String>(
          dataSource: tripsByDriver.entries.toList(),
          xValueMapper: (MapEntry<String, int> data, _) => data.key,
          yValueMapper: (MapEntry<String, int> data, _) => data.value,
          name: 'Chuyến đi',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  // Biểu đồ: Tổng thu nhập theo tài xế
  Widget buildIncomeByDriverChart(Map<String, double> incomeByDriver) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Tổng thu nhập theo tài xế (VNĐ)'),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<MapEntry<String, double>, String>(
          dataSource: incomeByDriver.entries.toList(),
          xValueMapper: (MapEntry<String, double> data, _) => data.key,
          yValueMapper: (MapEntry<String, double> data, _) => data.value,
          name: 'Thu nhập',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  // Biểu đồ: Tổng số chuyến đi theo ngày
  Widget buildTripsByDateChart(Map<String, int> tripsByDate) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Tổng số chuyến đi theo ngày'),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<MapEntry<String, int>, String>(
          dataSource: tripsByDate.entries.toList(),
          xValueMapper: (MapEntry<String, int> data, _) => data.key,
          yValueMapper: (MapEntry<String, int> data, _) => data.value,
          name: 'Chuyến đi',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  // Biểu đồ: Tổng thu nhập theo ngày
  Widget buildIncomeByDateChart(Map<String, double> incomeByDate) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Tổng thu nhập theo ngày (VNĐ)'),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<MapEntry<String, double>, String>(
          dataSource: incomeByDate.entries.toList(),
          xValueMapper: (MapEntry<String, double> data, _) => data.key,
          yValueMapper: (MapEntry<String, double> data, _) => data.value,
          name: 'Thu nhập',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CÁC BIỂU ĐỒ THỐNG KÊ"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Biểu đồ: Số chuyến đi theo tài xế
              const Text(
                "Số chuyến đi theo tài xế",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: buildTripsByDriverChart(tripsByDriver),
              ),

              const SizedBox(height: 20),

              // Biểu đồ: Tổng thu nhập theo tài xế
              const Text(
                "Tổng thu nhập theo tài xế",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: buildIncomeByDriverChart(incomeByDriver),
              ),

              const SizedBox(height: 20),

              // Biểu đồ: Tổng số chuyến đi theo ngày
              const Text(
                "Tổng số chuyến đi theo ngày",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: buildTripsByDateChart(tripsByDate),
              ),

              const SizedBox(height: 20),

              // Biểu đồ: Tổng thu nhập theo ngày
              const Text(
                "Tổng thu nhập theo ngày",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: buildIncomeByDateChart(incomeByDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
