import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:provider/provider.dart';
import '../appInfo/app_info.dart';
import '../global/global_var.dart';


///This PushNotificationService only you have to update with below code for new FCM Cloud Messaging V1 API
class PushNotificationService
{
  static Future<String> getAccessToken() async
  {
    final serviceAccountJson =
    {
      "type": "service_account",
      "project_id": "bookingapp-19efc",
      "private_key_id": "6f0e694300be71bcabdf31849591907cabedf363",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDSGPxMnbffnNod\nRalHIxMoyJqOIkLLS22EHgQRoIHHoCMqn3okccLVoLkvaNC7qGUbSCI/aZtKRfB1\nN8BYuOHGAii82XbKL7Zp7vGRgH3/wMSdNbfN8gd1SGSk3gBFrPkkxnpZHEdsd5Y1\nJKjseCvmbKYq6MZHJrNn3vS+9QCY6+AmM9XsvWO815E29xMhGyh1FKmN45mzS8AI\n9fIsb1V0h4jByPReB+JsKZLFJ41AdmaQYNhvJ0xpb8P17r1Jqpjid6EByeo2lRm+\n/IG9f19zTuK0UQfYkpaIcfz5QZHaSAKyl4yexFlb/r8AWn2ufcyv4PqW7uIWiX8I\n9ueahPU7AgMBAAECggEAWNUTqFlva27okkPoBRoBedcH8lzuHQLxdVEzqzhQZ1WA\nSP9RJ6OqG6VvZ2pMB2x2A4kGYgWHEWps90LxYxIY9B3pl5/jKC3wVO4g2cKYg9C/\n0TDrXHqfSKmpVERBnTQ7y57YEGFymZweuK2ddw6AkVcTE0WEwITOinasySjSbdVZ\na4erq4slVVNgP5NPYlTEmq0U0L9QUIFf7KlG3H+xvtOq6axcohZiSGDA14/2PNK4\nx+CHe1k2zPxPNQ+QoTqsuIAYiOMXpe265iWtObtR3Wyxypq4bh9GN3XEpJelKR4e\n5Honl9Or79hxfnQD+ZUO+ikMUkJOZ+bDw/Tmot78kQKBgQDbFXRMKYsrCO/aFiOa\nJtJk8CcJiJt7plHPfFJ9Qf9H2ao1o6Mj7qNZ/w3Gdd/w8zADU7ngVd7cg4SUFK/d\nhK4n8Zy9Ps1wyLtGWUX6lsvKmCG5iJ0NTTsSUR20U2ldh61Q/ZVITUNwtrOq4EZw\ngOkehqDKr3W2atXQr8jETu1o5QKBgQD1f+VxKIRYEo6DDQ9GJokS5uWJbLvUXaG1\nJSyZGJHh5t3AhtO8dQ5HSZYH/N1QURv8hGxwjVAHoU2TYoEP1upQzF+syIOqjNx1\n2VZXj0bY+WsQ+OLmov7JUEq67N4oAof+ybZFHPFq/MwXetegoP9hW+7iLXCzsnQk\nNP713LujnwKBgE3bL/spAFYI1QQRvhE4HqjUV2sh6u9kScqMidwNqiTki4KIZp+M\nXOzMoR6YIT9FjRiBlprMqWiALItbVqxITIPRbzwpp2SfUT5M13uYP0/+BG4kyHtD\nqOx3ezDsO5OLdeJEW9rX6lGR/AOLtDyi8zVv7pBZDmIHUXjaH2T0D5apAoGAJ2s4\n0RmbXnTkUyCWskHfwpw2gQFni2rZWzez2IU8b1RdiNtdRiZZe5LSN0gf1RSg9MPi\nkZPvJLp+tUqcxIlSqFSYjCrKEWl6wKV8GqUT0CUETv5XmIbVeEefKDJ+XVhCs+N5\nk9FY5j/fGWoNE2qmduCHE+QN85yUz3d+9MVTj6sCgYEA2Qacy+4iMMDpk4l/WWaA\nHgd9kygfb2Ih1HtjqzNfy651OisLIKXNk6PBygmMNcB/YFkktkvXYn5sS8Yarczh\nDVHF5fMDXdh42mQqmeGkcYBCXAyF+hYYAdf3QTkuLeC0trtOMdciTc4v1FjHUs5r\nz7h6lzgyP+I+pY1iPtAyqSM=\n-----END PRIVATE KEY-----\n",
      "client_email": "bookingapp-19efc@appspot.gserviceaccount.com",
      "client_id": "108416883804838840612",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/bookingapp-19efc%40appspot.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes =
    [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",  //sử dụng tin nhắn đám mây để gửi thông báo
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async
  {
    String dropOffDestinationAddress = Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName.toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName.toString();

    final String serverAccessTokenKey = await getAccessToken() ; // Your FCM server access token key
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/bookingapp-19efc/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken, // Token of the device you want to send the message/notification to
        'notification': {
          "title": "Yêu cầu chuyến đi từ $userName",
          "body": "Điểm đón: $pickUpAddress \nĐiểm trả: $dropOffDestinationAddress",
        },
        'data': {
          "tripID": tripID,
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Tin nhắn được gửi thành công');
    } else {
      print('Gửi tin nhắn thất bại: ${response.statusCode}');
    }
  }
}