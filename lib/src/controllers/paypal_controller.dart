import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
// ignore: prefer_relative_imports
import 'package:markets/src/elements/PaymentMethodListItemWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/address.dart';

class PayPalController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  Address deliveryAddress;

  PayPalController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  // Future<String> getString() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // url = prefs.getString("PaymentUrl") ?? "null";

  //   return url;
  // }

  @override
  Future<void> initState() async {
    // final String _apiToken = 'api_token=${userRepo.currentUser.value.apiToken}';
    // final String _userId = 'user_id=${userRepo.currentUser.value.id}';
    // final String _deliveryAddress =
    //     'delivery_address_id=${settingRepo.deliveryAddress.value?.id}';

    // await getString();
    // if (url == "null") {
    //   url = "https://baqalaapp.ae/payment";
    // }
    // url =
    //     "https://www.paytabs.com/sI12vHcAeV9NqDYdhPVijrJmcQrxWJw09P_K2DjlyFri748/jqW6PHjIz8Pz5gvmQUqRXd0j6gjmkWnYapLYYoMG5UVlnX0/CstPsi4znhPIAWFJdBiSFf1ZkveQzPKqsimC61BpmrFtsB0/EoCNcdJyzekdtYUjrFkoa6wI4n7aNnIhB8BACMmDAzUPZmsGRCGqcYyhNMBDeSAEtUVkXMZSpN8Mr8V_MZaygmZOVg";

    // url =
    //     '${GlobalConfiguration().getString('base_url')}payments/paypal/express-checkout?$_apiToken&$_userId&$_deliveryAddress';
    // url = 'https://www.google.com';
    url = PaymentMethodListItemWidget.myURL;
    print('PAYPAL URLL : ' + url);
    setState(() {});
    super.initState();
  }
}
