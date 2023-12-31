import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 15))
        ..repeat();
  bool activeConnection = false;

  late WebViewPlusController myWebViewController;
  bool isWebViewLoading = true;
  bool showHome = true;

  @override
  void initState() {
    checkUserConnection();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var centerSize = MediaQuery.of(context).size.shortestSide;
    var maxWidth = MediaQuery.of(context).size.width;
    var maxHeight = MediaQuery.of(context).size.height;
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;
    centerSize = centerSize - (centerSize * 0.35);

    return WillPopScope(
        child: Stack(
          children: [
            Positioned(
              top: statusBarHeight,
              child: SizedBox(
                  height: maxHeight - statusBarHeight,
                  width: maxWidth,
                  child: WebViewPlus(
                    initialUrl: 'https://mbvt.netlify.app/',
                    onWebViewCreated: (controller) {
                      myWebViewController = controller;
                    },
                    onPageFinished: (finish) {
                      Future.delayed(const Duration(seconds: 3)).then((value) {
                        setState(() {
                          isWebViewLoading = false;
                        });
                      });
                    },
                    javascriptMode: JavascriptMode.unrestricted,
                  )),
            ),
            Visibility(
                visible: showHome,
                child: Scaffold(
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: Stack(
                      children: [
                        Visibility(
                          visible: isWebViewLoading,
                          child: Image.asset("assets/loader.gif")
                        ),
                        Visibility(
                          visible: !isWebViewLoading,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(width: 2.0, color: Colors.black),
                            ),
                            onPressed: () {
                              setState(() {
                                showHome = false;
                              });
                            },
                            child: const Text(
                              'Start Virtual Tour',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.lightBlueAccent[100],
                    body: DoubleBackToCloseApp(
                      snackBar: const SnackBar(
                        content: Text('Tap back again to close app.'),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Container(
                            padding: const EdgeInsets.only(
                                top: 30, left: 20, right: 20, bottom: 75),
                            child: Image.asset("assets/sideElementNV.png"),
                          )),
                          Center(
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: _controller.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: Image.asset("assets/circleNV.PNG",
                                  height: centerSize, width: centerSize),
                            ),
                          ),
                          Positioned(
                            bottom: centerSize / 2,
                            child: SizedBox(
                                width: maxWidth,
                                child: Center(
                                  child: DefaultTextStyle(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                        color: Colors.black,
                                        fontFamily: 'TiltNeon'),
                                    textAlign: TextAlign.center,
                                    child: AnimatedTextKit(
                                      totalRepeatCount: 1,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                            "Raj Bhawan Dehradun",
                                          speed: const Duration(milliseconds: 150)
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )))
          ],
        ),
        onWillPop: () async {
          setState(() {
            showHome = true;
          });
          return false;
        });
  }

  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          activeConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        activeConnection = false;
        closeApp();
      });
    }
  }

  void closeApp() {
    Fluttertoast.showToast(
        msg: "Please connect to Internet first.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3);
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}
