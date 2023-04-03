import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:Prizm/PermissionManage.dart';
import 'package:Prizm/vmidc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Settings.dart';
import 'main.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {

  // String? defaultNameExtractor(RouteSettings settings) => settings.name;
  Future <void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: 'ios Home');
  }

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final double _size = 220;

  final VMIDC _vmidc = VMIDC();

  // final PermissionManage _permissionManager = PermissionManage();
  final _ctrl = StreamController<List>();
  String _id = '';

  late var settingIcon = ImageIcon(Image.asset('assets/settings.png').image);

  late dynamic _background =
      const ColorFilter.mode(Colors.transparent, BlendMode.clear);

  late var _textSpan_light = const TextSpan(children: [
      TextSpan(
        text: '지금 이 곡을 찾으려면 ',
        style: TextStyle(fontSize: 17, color: Colors.black),
      ),
      TextSpan(
        text: '프리즘 ',
        style: TextStyle(
            color: Color.fromRGBO(43, 226, 193, 1),
            fontSize: 17,
            fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: '을 눌러주세요!',
        style: TextStyle(fontSize: 17, color: Colors.black),
      ),
  ]);

  late TextSpan _textSpan_dark = const TextSpan(children: [
    TextSpan(
      text: '지금 이 곡을 찾으려면 ',
      style: TextStyle(fontSize: 17, color: Colors.white),
    ),
    TextSpan(
      text: '프리즘 ',
      style: TextStyle(
          color: Color.fromRGBO(43, 226, 193, 1),
          fontSize: 17,
          fontWeight: FontWeight.bold),
    ),
    TextSpan(
      text: '을 눌러주세요!',
      style: TextStyle(fontSize: 17, color: Colors.white),
    ),
  ]);


/*--------------------------------------------------------------*/

  @override
  void initState() {
    logSetscreen();
    Permission.microphone.request();
    // _permissionManager.requestMicPermission(context);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _vmidc.init(ip: '222.122.131.220', port: 8551, sink: _ctrl.sink).then((ret) {
      if (!ret) {
        print('server error');
      } else {
        _ctrl.stream.listen((data) async {
          if (data.length == 2) {
            _id = '${data[0]} (${data[1]})';
          } else {
            _id = 'error';
          }
          await _vmidc.stop();
          print('_vmidc.isRuning() : ${_vmidc.isRunning()}');
          setState(() {});
        });
      }
    });
    _permission();
    super.initState();
  }

  @override
  void dispose() {
    _vmidc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    double c_height = MediaQuery.of(context).size.height;
    double c_width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isTransParent = settingIcon.color == const Color(0x00000000);
    final isPad = c_width > 550;
    final isFlip = c_height > 800;
    return WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: isDarkMode
                ? const Color.fromRGBO(47, 47, 47, 1)
                : const Color.fromRGBO(244, 245, 247, 1),
            title: Image.asset(
              isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
              height: 25,
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Image.asset('assets/x_icon.png', width: 20,
                color: isTransParent ? isDarkMode ? Colors.white : Colors.grey : Colors.transparent),
              splashColor: Colors.transparent,
              onPressed: () {
                MyApp.analytics.logEvent(name: 'ios x 검색취소');
                _vmidc.stop();
                isTransParent
                    ? Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()))
                    : const Text('');
              },
            ),
            actions: [
              IconButton(
                icon: settingIcon,
                splashColor: Colors.transparent,
                visualDensity: const VisualDensity(horizontal: 4.0),
                color: isDarkMode ? Colors.white : Colors.black,
                onPressed: () {
                  isTransParent
                      ? null
                      : Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()),
                  );
                },
              )
            ],
            centerTitle: true,
            toolbarHeight: 90,
            elevation: 0.0,
          ),
          body: Container(
              width: double.infinity,
              color: isDarkMode
                  ? const Color.fromRGBO(47, 47, 47, 1)
                  : const Color.fromRGBO(244, 245, 247, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: c_height * 0.55,
                      padding: const EdgeInsets.only(bottom: 50),
                      decoration: isPad
                          ? BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(isDarkMode
                                      ? 'assets/BG_dark.gif'
                                      : 'assets/BG_light.gif'),
                                  alignment: const Alignment(0, -1.8),
                                  fit: BoxFit.cover,
                                  colorFilter: _background))
                          : BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      isDarkMode ? 'assets/BG_dark.gif' : 'assets/BG_light.gif'
                                  ),
                                  alignment: isFlip ? const Alignment(0, 1) : const Alignment(0, 3),
                                  colorFilter: _background
                              )
                      ),
                      child: Center(
                          child: Column(children: <Widget>[
                        Center(
                            child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: RichText(
                              text: isDarkMode ? _textSpan_dark : _textSpan_light
                          ),
                        )),
                        IconButton(
                            icon: isDarkMode
                                ? Image.asset('assets/_prizm_dark.png')
                                : Image.asset('assets/_prizm.png'),
                            padding: const EdgeInsets.only(bottom: 30),
                            iconSize: _size,
                            onPressed: () async {
                              _permission();
                              var status = await Permission.microphone.status;
                              if (status == PermissionStatus.denied) {
                                PermissionToast();
                                return;
                              } else if (status ==
                                  PermissionStatus.permanentlyDenied) {
                                PermissionToast();
                                return _showDialog();
                              }
                              print(_connectionStatus);
                              if (_connectionStatus.endsWith('none') == true) {
                                NetworkToast();
                                return;
                              } else if (await Permission
                                      .microphone.status.isGranted &&
                                  _connectionStatus.endsWith('none') == false) {
                                _vmidc.start();
                                setState(() {
                                  settingIcon = ImageIcon(Image.asset('assets/settings.png').image,
                                      color: Colors.transparent
                                  );
                                  isDarkMode
                                  ? _textSpan_dark = const TextSpan(
                                    text: '노래 분석중',
                                    style: TextStyle(
                                        color: Color.fromRGBO(43, 226, 193, 1),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold
                                    )
                                  )
                                    : _textSpan_light = const TextSpan(
                                  text: '노래 분석중',
                                  style: TextStyle(
                                  color: Color.fromRGBO(43, 226, 193, 1),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                                  );
                                  _background = const ColorFilter.mode(
                                      Colors.transparent, BlendMode.color
                                  );
                                });

                                if (_vmidc.isRunning() == true) {
                                  _vmidc.stop();
                                  await MyApp.analytics.logEvent(name: 'ios Prizm 검색취소');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));
                                }
                              }
                            }),
                          ]
                        )
                      )
                  ),
                ],
              )
          ),
        )
    );
  }

  Future<bool> _onBackKey() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
      context: context,
      barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 400,
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              height: 150,
              color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 90,
                    child: Center(
                      child: Text(
                        '종료하시겠습니까?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: isDarkMode
                                    ? const Color.fromRGBO(94, 94, 94, 1)
                                    : Colors.black.withOpacity(0.1)
                            )
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 78,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(66, 66, 66, 1)
                                      : Colors.white,
                                  border: Border(
                                      right: BorderSide(
                                          color: isDarkMode
                                              ? const Color.fromRGBO(
                                                  94, 94, 94, 1)
                                              : Colors.black
                                                  .withOpacity(0.1)))),
                              margin: const EdgeInsets.only(left: 20),
                              child: TextButton(
                                  onPressed: () {
                                    exit(0);
                                  },
                                  child: const Text(
                                    '종료',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ))),
                        ),
                        Container(
                            margin: const EdgeInsets.only(right: 20),
                            color: isDarkMode
                                ? const Color.fromRGBO(66, 66, 66, 1)
                                : Colors.white,
                            width: 180,
                            height: 78,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.3),
                                ),
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isGranted && status.isLimited) {
      // isLimited - 제한적 동의 (Ios 14 < )
      print('isGranted');
      if (await Permission.microphone.isGranted) {
        print('finally granted');
      } else if (requestStatus.isPermanentlyDenied ||
          status.isPermanentlyDenied) {
        print("isPermanentlyDenied");
        openAppSettings();
      } else if (status.isDenied) {
        print('isDenied');
      }
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = '네트워크 연결을 확인 해주세요.');
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  // Future<bool> requestMicPermission(BuildContext context) async {
  //   PermissionStatus status = await Permission.microphone.request();
  //   print('permission manage >> $status');
  //   if(!status.isGranted) {
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           print('status => $status');
  //         }
  //     );
  //     return false;
  //   }
  //   return true;
  // }

  Future<void> _showDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: 400,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                height: 150,
                color: isDarkMode
                    ? const Color.fromRGBO(66, 66, 66, 1)
                    : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: const Center(
                        child: Text('마이크 권한을 허용 해주세요.',
                            style: TextStyle(fontSize: 23)),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(right: 20, top: 40),
                        child: (TextButton(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: const Text(
                            '설정하기',
                            style: TextStyle(color: Colors.blue, fontSize: 20),
                          ),
                        )))
                  ],
                ),
              ));
        });
  }
}
// _showDialog(BuildContext context) {
//   return AlertDialog(
//     content: const Text('마이크 권한을 확인해주세요'),
//     actions: [
//       TextButton(
//         onPressed: () {
//           openAppSettings();
//         },
//         child: const Text('설정하기',
//           style: TextStyle(
//               color: Colors.blue
//           ),
//         ),
//       )
//     ],
//   );
// }
/*getPermission() async {
  var status = await Permission.microphone.status;
  if(status.isGranted){
    print('confirm');
  }else if(status.isLimited){
    Permission.microphone.request();
    print('limited');
  }else if(status.isDenied) {
    print('denied');
    Permission.microphone.request();
  }else if(await Permission.microphone.isPermanentlyDenied) {
    openAppSettings();
  }
}*/

void NetworkToast() {
  Fluttertoast.showToast(
      msg: '네트워크 연결을 확인 해주세요.',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER);
}

void PermissionToast() {
  Fluttertoast.showToast(
      msg: '마이크 권한을 허용해주세요.',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM);
}
