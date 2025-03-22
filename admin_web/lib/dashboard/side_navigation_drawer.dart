import 'package:admin_web/dashboard/dashboard.dart';
import 'package:admin_web/page/drivers_page.dart';
import 'package:admin_web/page/login.dart';
import 'package:admin_web/page/trips_page.dart';
import 'package:admin_web/page/users_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = const Center(child: CircularProgressIndicator());
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Dữ liệu từ Firebase
  Map<String, int> tripsByDriver = {};
  Map<String, double> incomeByDriver = {};
  Map<String, int> tripsByDate = {};
  Map<String, double> incomeByDate = {};

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  // Lấy dữ liệu thực từ Firebase
  Future<void> fetchDataFromFirebase() async {
    final ref = _database.ref("tripRequests");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      Map data = snapshot.value as Map;

      Map<String, int> driverTrips = {};
      Map<String, double> driverIncome = {};
      Map<String, int> dateTrips = {};
      Map<String, double> dateIncome = {};

      data.forEach((key, value) {
        String driverName = value["driverName"] ?? "Unknown";
        String date = value["publishDateTime"]?.split(" ")?.first ?? "Unknown";
        double fareAmount = double.tryParse(value["fareAmount"].toString()) ?? 0.0;

        // Số chuyến đi theo tài xế
        driverTrips[driverName] = (driverTrips[driverName] ?? 0) + 1;

        // Tổng thu nhập theo tài xế
        driverIncome[driverName] = (driverIncome[driverName] ?? 0) + fareAmount;

        // Số chuyến đi theo ngày
        if (date != "Unknown") {
          dateTrips[date] = (dateTrips[date] ?? 0) + 1;

          // Tổng thu nhập theo ngày
          dateIncome[date] = (dateIncome[date] ?? 0) + fareAmount;
        }
      });

      setState(() {
        tripsByDriver = driverTrips;
        incomeByDriver = driverIncome;
        tripsByDate = dateTrips;
        incomeByDate = dateIncome;
        chosenScreen = Dashboard(
          tripsByDriver: tripsByDriver,
          incomeByDriver: incomeByDriver,
          tripsByDate: tripsByDate,
          incomeByDate: incomeByDate,
        );
      });
    }
  }

  // Điều hướng đến trang được chọn
  void sendAdminTo(AdminMenuItem selectedPage) {
    switch (selectedPage.route) {
      case Dashboard.id:
        setState(() {
          chosenScreen = Dashboard(
            tripsByDriver: tripsByDriver,
            incomeByDriver: incomeByDriver,
            tripsByDate: tripsByDate,
            incomeByDate: incomeByDate,
          );
        });
        break;

      case DriversPage.id:
        setState(() {
          chosenScreen = const DriversPage();
        });
        break;

      case UsersPage.id:
        setState(() {
          chosenScreen = const UsersPage();
        });
        break;

      case TripsPage.id:
        setState(() {
          chosenScreen = const TripsPage();
        });
        break;

      default:
        setState(() {
          chosenScreen = const Center(child: Text("Không tìm thấy trang"));
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade700,
        title: const Text(
          "Admin Web",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: "Trang chủ",
            route: Dashboard.id,
            icon: CupertinoIcons.home,
          ),
          AdminMenuItem(
            title: "Tài xế",
            route: DriversPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          AdminMenuItem(
            title: "Người dùng",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Chuyến đi",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
        ],
        selectedRoute: Dashboard.id,
        onSelected: (selectedPage) {
          sendAdminTo(selectedPage);
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: Colors.pink.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color: Colors.pink.shade500,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),  // Đăng xuất
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()),  // Chuyển đến màn hình đăng nhập
                  );
                },
              ),
              const SizedBox(width: 10),
              const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}
