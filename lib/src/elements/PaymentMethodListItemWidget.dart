import 'package:flutter/material.dart';
import 'package:markets/src/controllers/cart_controller.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../models/payment_method.dart';
import 'dart:convert';

class PaytabsData {
  final String merchant_email = 'bilal@baqalaapp.ae';
  final String secret_key =
      'd03GIVRqUb5wT2STugPEIj5mjzgUt31G44nM0fdUqiqkkjdPz2uhmzEF8VACYBj2GHPHW2Bnl2HFmVvVYZdkyRZHMAjLcCOTjDAg';
  final String currency = 'AED';
  final String amount;
  final String site_url = 'https://baqalaapp.ae/';
  final String title = 'BaqalaApp';
  final String quantity = '1';
  final String unit_price;
  final String products_per_title = '1';
  final String return_url = 'https://baqalaapp.ae/';
  final String cc_first_name;
  final String cc_last_name;
  final String cc_phone_number = '12312312312';
  final String phone_number;
  final String billing_address;
  final String city = 'Dubai';
  final String state = 'Dubai';
  final String postal_code = '00000';
  final String country_shipping = 'ARE';
  final String country = 'ARE';
  final String email;
  final String ip_customer = '192.168.0.11';
  final String ip_merchant = '192.168.0.1';
  final String address_shipping = 'Dubai UAE';
  final String city_shipping = 'Dubai';
  final String state_shipping = 'Dubai';
  final String postal_code_shipping = '00000';
  final String other_charges = '0';
  final String reference_no = '1231231';
  final String msg_lang = 'english';
  final String cms_with_version = 'API USING PHP';

  PaytabsData(this.email, this.phone_number, this.billing_address, this.amount,
      this.unit_price, this.cc_first_name, this.cc_last_name);

  PaytabsData.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        phone_number = json['phone_number'],
        billing_address = json['billing_address'],
        amount = json['amount'],
        unit_price = json['unit_price'],
        cc_first_name = json['cc_first_name'],
        cc_last_name = json['cc_last_name'];

  Map<String, dynamic> toJson() => {
        'merchant_email': merchant_email,
        'secret_key': secret_key,
        'currency': currency,
        'amount': amount,
        'site_url': site_url,
        'title': title,
        'quantity': quantity,
        'unit_price': unit_price,
        'products_per_title': products_per_title,
        'return_url': return_url,
        'cc_first_name': cc_first_name,
        'cc_last_name': cc_last_name,
        'cc_phone_number': cc_phone_number,
        'phone_number': phone_number,
        'billing_address': billing_address,
        'city': city,
        'state': state,
        'postal_code': postal_code,
        'country_shipping': country_shipping,
        'country': country,
        'email': email,
        'ip_customer': ip_customer,
        'ip_merchant': ip_merchant,
        'address_shipping': address_shipping,
        'city_shipping': city_shipping,
        'state_shipping': state_shipping,
        'postal_code_shipping': postal_code_shipping,
        'other_charges': other_charges,
        'reference_no': reference_no,
        'msg_lang': msg_lang,
        'cms_with_version': cms_with_version
      };

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["merchant_email"] = merchant_email;
    map["secret_key"] = secret_key;
    map["currency"] = currency;
    map["amount"] = amount;
    map["site_url"] = site_url;
    map["title"] = title;
    map["quantity"] = quantity;
    map["unit_price"] = unit_price;
    map["products_per_title"] = products_per_title;
    map["return_url"] = return_url;
    map["cc_first_name"] = cc_first_name;
    map["cc_last_name"] = cc_last_name;
    map["cc_phone_number"] = cc_phone_number;
    map["phone_number"] = phone_number;
    map["billing_address"] = billing_address;
    map["city"] = city;
    map["state"] = state;
    map["postal_code"] = postal_code;
    map["country"] = country;
    map["email"] = email;
    map["ip_customer"] = ip_customer;
    map["ip_merchant"] = ip_merchant;
    map["city_shipping"] = city_shipping;
    map["state_shipping"] = state_shipping;
    map["postal_code_shipping"] = postal_code_shipping;
    map["other_charges"] = other_charges;
    map["reference_no"] = reference_no;
    map["msg_lang"] = msg_lang;
    map["cms_with_version"] = cms_with_version;
    map["address_shipping"] = address_shipping;
    map["country_shipping"] = country_shipping;

    return map;
  }
}

// ignore: must_be_immutable
class PaymentMethodListItemWidget extends StatelessWidget {
  String heroTag;
  PaymentMethod paymentMethod;
  PaytabsData _paytabsData;

  static String myURL;

  PaymentMethodListItemWidget({Key key, this.paymentMethod}) : super(key: key);

  Future<void> setURL(url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("PaymentUrl", url);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () async {
        print("printing route");
        print(this.paymentMethod.route);
        Navigator.of(context).pushNamed(this.paymentMethod.route);
        //TESTT HIDING PAYTABS METHOD
        // if (this.paymentMethod.name == 'PayTabs') {
        //   Alert(
        //     context: context,
        //     type: AlertType.none,
        //     title: "Dear Customer",
        //     desc: "This Feature Is Coming Soon",
        //     buttons: [
        //       DialogButton(
        //         child: Text(
        //           "Ok",
        //           style: TextStyle(color: Colors.white, fontSize: 20),
        //         ),
        //         onPressed: () => Navigator.pop(context),
        //         width: 120,
        //       )
        //     ],
        //   ).show();
        //   // print('PayTabs ' + CartController.totalBill.toString());
        //   // print('PayTabs ' + this.paymentMethod.name);
        //   // print('PayTabs ' + currentUser.value.name);
        //   // print('PayTabs ' + currentUser.value.email);
        //   // print('PayTabs ' + currentUser.value.phone);
        //   // print('PayTabs ' + currentUser.value.address);
        //
        //   // _paytabsData = new PaytabsData(
        //   //     currentUser.value.email,
        //   //     '12312312312',
        //   //     currentUser.value.address,
        //   //     CartController.totalBill.toString(),
        //   //     CartController.totalBill.toString(),
        //   //     currentUser.value.name,
        //   //     currentUser.value.name);
        //
        //   // print('PAYTABS DATA: ' + _paytabsData.merchant_email);
        //
        //   // final String url = 'https://www.paytabs.com/apiv2/create_pay_page';
        //   // final client = new http.Client();
        //   // Map params = _paytabsData.toMap();
        //   // final response = await client.post(
        //   //   url,
        //   //   body: params,
        //   // );
        //   // print(json.decode(response.body));
        //   // if (json.decode(response.body)['response_code'] == '4012') {
        //   //   // print('api success! ' + json.decode(response.body)['payment_url']);
        //   //   myURL = json.decode(response.body)['payment_url'];
        //   //   this.setURL(json.decode(response.body)['payment_url']);
        //   //   Navigator.of(context).pushNamed("/PayPal");
        //
        //   //   // _launched =
        //   //   //     _launchInBrowser(json.decode(response.body)['payment_url']);
        //   // }
        // } else {
        //   Navigator.of(context).pushNamed(this.paymentMethod.route);
        // }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                    image: AssetImage(paymentMethod.logo), fit: BoxFit.fill),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          paymentMethod.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          paymentMethod.description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).focusColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
