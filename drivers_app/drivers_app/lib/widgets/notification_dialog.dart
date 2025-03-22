import 'dart:async';

import 'package:drivers_app/global/global_var.dart';
import 'package:drivers_app/methods/common_methods.dart';
import 'package:drivers_app/models/trip_details.dart';
import 'package:drivers_app/pages/new_trip_page.dart';
import 'package:drivers_app/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class NotificationDialog extends StatefulWidget
{
  final TripDetails? tripDetailsInfo;

  const NotificationDialog({super.key, this.tripDetailsInfo,});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog>
{
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();

  cancelNotificationDialogAfter20Sec()
  {
    const oneTickPerSecond = Duration(seconds: 1);

    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer)
    {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;

      if(tripRequestStatus == "accepted")
      {
        timer.cancel();
        driverTripRequestTimeout = 20;
      }

      if(driverTripRequestTimeout == 0)
      {
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout = 20;
        audioPlayer.stop();
      }
    });
  }

  checkAvailabilityOfTripRequest(BuildContext context) async
  {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: 'Vui lòng đợi...',),
    );

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once()
        .then((snap)
    {
      Navigator.pop(context); //đóng hộp thoại thông báo
      Navigator.pop(context);

      //khởi tạo biến cung cấp cho nó giá trị trạng thái chuyến đi mới
      String newTripStatusValue = "";
      if(snap.snapshot.value != null)  //nếu trạng thi chuyến đi mới khác null
      {
        //gán nó cho biến giá trị trạng thái chuyến đi mới
        newTripStatusValue = snap.snapshot.value.toString();
      }
      else  //nếu trạng thái chuyến đi mới không tồn tại
      {
        cMethods.displaySnackBar("Không tìm thấy yêu cầu chuyến đi.", context);
      }
    //nếu giá trị trạng thái chuyến đi mới bằng với ID chuyến đi
      if(newTripStatusValue == widget.tripDetailsInfo!.tripID)
      {
        driverTripStatusRef.set("accepted");

        //Tắt cập nhật vị trí trang chủ
        cMethods.turnOffLocationUpdatesForHomePage();

        Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripPage(newTripDetailsInfo: widget.tripDetailsInfo)));
      }
      else if(newTripStatusValue == "cancelled")
      {
        cMethods.displaySnackBar("Yêu cầu chuyến đi đã bị hủy bởi người dùng.", context);
      }
      else if(newTripStatusValue == "timeout")
      {
        cMethods.displaySnackBar("Yêu cầu chuyến đi đã hết thời gian chờ.", context);
      }
      else
      {
        cMethods.displaySnackBar("Đã xóa Yêu cầu chuyến đi. Không tìm thấy.", context);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    cancelNotificationDialogAfter20Sec();
  }

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 30.0,),

            Image.asset(
              "assets/images/Taxi1.png",
              width: 140,
            ),

            const SizedBox(height: 16.0,),

            //title
            const Text(
              "YÊU CẦU CHUYẾN ĐI MỚI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const  SizedBox(height: 20.0,),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 10.0,),

            //pick - dropoff
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [

                  //pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        "assets/images/initial.png",
                        height: 16,
                        width: 16,
                      ),

                      const SizedBox(width: 18,),

                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.pickupAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15,),

                  //dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        "assets/images/final.png",
                        height: 16,
                        width: 16,
                      ),

                      const SizedBox(width: 18,),

                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.dropOffAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20,),

            const Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),

            const SizedBox(height: 8,),

            //decline btn - accept btn
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text(
                        "TỪ CHỐI",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        audioPlayer.stop();

                        setState(() {
                          tripRequestStatus = "accepted";
                        });
                      //kiểm tra tính khả dụng cho yêu cầu chuyến đi
                        checkAvailabilityOfTripRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "CHẤP NHẬN",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 10.0,),

          ],
        ),
      ),
    );
  }
}
