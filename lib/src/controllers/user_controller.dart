import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);

      repository.login(user).then((value)
      {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void preRegisterShop(
      {String name,
      String email,
      String shopName,
      String shopAddress,
      String phone}) async {
    FocusScope.of(context).unfocus();

    Overlay.of(context).insert(loader);

    print(name);
    print(email);
    print(shopName);
    print(shopAddress);
    print(phone);

    repository
        .registerUserShop(
            name: name,
            email: email,
            shopAddress: shopAddress,
            shopName: shopName,
            phone: phone)
        .then((value) {
      if (value) {
        print("done");
        print(value);

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              "Successfully registered!",
              style: TextStyle(
                color: Colors.green,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed('/Pages', arguments: 2);
                },
                child: Text("Done"),
              ),
            ],
          ),
        );
      } else {
        print("crashed");

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              "Registration Failed !",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            content: Text("Try again with different email or phone."),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("Okay"),
              ),
            ],
          ),
        );
      }
    }).catchError((e) {
      print("caught error");
      loader.remove();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            "Registration Failed !",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          content: Text("Try again"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("Okay"),
            ),
          ],
        ),
      );
    }).whenComplete(() {
      print("success");
      Helper.hideLoader(loader);
    });

    //   repository.register(user).then((value) {
    //     if (value != null && value.apiToken != null) {
    //       Navigator.of(scaffoldKey.currentContext)
    //           .pushReplacementNamed('/Pages', arguments: 2);
    //     } else {
    //       scaffoldKey?.currentState?.showSnackBar(SnackBar(
    //         content: Text(S.of(context).wrong_email_or_password),
    //       ));
    //     }
    //   }).catchError((e) {
    //     loader.remove();
    //     scaffoldKey?.currentState?.showSnackBar(SnackBar(
    //       content: Text(S.of(context).this_email_account_exists),
    //     ));
    //   }).whenComplete(() {
    //     Helper.hideLoader(loader);
    //   });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content:
                Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
