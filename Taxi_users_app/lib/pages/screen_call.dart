import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
 // Đảm bảo đường dẫn đúng tới navigatorKey

class ScreenCall extends StatefulWidget {
  final String channelName;
  final bool isCaller;

  const ScreenCall({required this.channelName, required this.isCaller});

  @override
  _ScreenCallState createState() => _ScreenCallState();
}

class _ScreenCallState extends State<ScreenCall> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Yêu cầu quyền camera và microphone
    await [Permission.microphone, Permission.camera].request();

    // Khởi tạo Agora Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: 'c75f1665dcde41efa1cfa08d11fd853b')); // Điền App ID chính xác của bạn

    // Đặt Channel Profile và Client Role với tham số đặt tên
    await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await _engine.setClientRole(
      role: widget.isCaller ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
    );

    // Đăng ký sự kiện
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print("Joined channel: ${connection.channelId}, uid: ${connection.localUid}");
        setState(() {
          _localUserJoined = true;
        });
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print("User joined: $remoteUid");
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        print("User offline: $remoteUid");
        setState(() {
          _remoteUid = null;
        });
      },
      onError: (error, message) {
        print("Error: $error, $message");
      },
    ));

    // Bật video
    await _engine.enableVideo();

    // Tham gia kênh
    await _engine.joinChannel(
      token: "", // Nếu đã tắt App Certificate, để chuỗi rỗng
      channelId: widget.channelName,
      uid: 0, // Để 0 để Agora tự động gán UID
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _renderLocalPreview() {
    if (_localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Text('Đang chờ...', style: TextStyle(color: Colors.white));
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid!),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text('Đang chờ đối tác...', style: TextStyle(color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: widget.isCaller ? _renderRemoteVideo() : _renderLocalPreview()),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
