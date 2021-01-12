import 'package:flutter/material.dart';
import 'package:markets/generated/l10n.dart';
import 'package:markets/src/models/setting.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/splash_screen_controller.dart';
import 'package:get_version/get_version.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  void loadData()
  {
    print("splash load Data start");
    _con.progress.addListener(() {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        try {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
        } catch (e) {}
      }
    });
    print("in splash loadData completed");
  }

  @override
  void initState()
  {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    print("in splash build");
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
            // color: Colors.grey[900],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment(-1.0, -1.0),
                colors: [const Color(0xffB1FFB6), const Color(0xffB5F3B0)])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset(
                'assets/img/logo25.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Shop From Your Favourite Grocers",
                style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 21.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.withOpacity(0.8),
                    height: 1.3),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              Spacer(),
              Text(
                "Town Stores Network (TSN)",
                style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 19.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.6),
                    height: 1.3),
                textAlign: TextAlign.end,
              ),
              SizedBox(height: 10.0),
              Text(
                Setting.projectVersion != null ? S.of(context).version + " " + Setting.projectVersion : '',
                style: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.bold,
                ),
              ),
//            Spacer(),
              SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
      // body: Container(
      //   decoration: BoxDecoration(
      //       // color: Colors.grey[900],
      //       gradient: LinearGradient(
      //           begin: Alignment.centerLeft,
      //           end: Alignment(-1.0, -1.0),
      //           colors: [const Color(0xffB1FFB6), const Color(0xffB5F3B0)])),
      //   child: Center(
      //     child: Column(
      //       mainAxisSize: MainAxisSize.max,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         SizedBox(height: 210),
      //         FittedBox(
      //           child: Image.asset(
      //             'assets/img/logo2.png',
      //             width: 150,
      //             fit: BoxFit.cover,
      //             // fit: BoxFit.fill,
      //           ),
      //         ),
      //         SizedBox(height: 10),
      //         Text('Shop From Your Favorite Grocers',
      //             style: TextStyle(
      //                 fontFamily: 'ProductSans',
      //                 fontSize: 21.0,
      //                 fontStyle: FontStyle.italic,
      //                 fontWeight: FontWeight.w700,
      //                 color: Colors.green.withOpacity(0.8),
      //                 height: 1.3),
      //             textDirection: TextDirection.ltr),
      //         SizedBox(height: 30),
      //         CircularProgressIndicator(
      //           valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      //         ),
      //         SizedBox(height: 170),
      //         Text('Town Store Network (TSN)',
      //             style: TextStyle(
      //                 fontFamily: 'ProductSans',
      //                 fontSize: 19.0,
      //                 fontWeight: FontWeight.w700,
      //                 color: Colors.black.withOpacity(0.6),
      //                 height: 1.3),
      //             textDirection: TextDirection.ltr),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
