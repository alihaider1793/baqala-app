import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
// import 'package:flutter_paytabs_bridge_emulator/flutter_paytabs_bridge_emulator.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  PaymentMethodsWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  PaymentMethodList list;

  // String _result = '---';
  // String _instructions = 'Tap on "Pay" Button to try PayTabs plugin';

  // Future<void> payPressed() async {
  //   print('trying to do something');
  //   Navigator.of(context).pushNamed("/PayPal");
  // }

  // Future<void> payPressed() async {
  //   var args = {
  //     pt_merchant_email: "bilal@baqalaapp.ae",
  //     pt_secret_key:
  //         "d03GIVRqUb5wT2STugPEIj5mjzgUt31G44nM0fdUqiqkkjdPz2uhmzEF8VACYBj2GHPHW2Bnl2HFmVvVYZdkyRZHMAjLcCOTjDAg", // Add your Secret Key Here
  //     pt_transaction_title: "Mr. John Doe",
  //     pt_amount: "2.0",
  //     pt_currency_code: "USD",
  //     pt_customer_email: "test@example.com",
  //     pt_customer_phone_number: "+97333109781",
  //     pt_order_id: "1234567",
  //     product_name: "Tomato",
  //     pt_timeout_in_seconds: "300", //Optional
  //     pt_address_billing: "test test",
  //     pt_city_billing: "Juffair",
  //     pt_state_billing: "state",
  //     pt_country_billing: "BHR",
  //     pt_postal_code_billing:
  //         "00973", //Put Country Phone code if Postal code not available '00973'//
  //     pt_address_shipping: "test test",
  //     pt_city_shipping: "Juffair",
  //     pt_state_shipping: "state",
  //     pt_country_shipping: "BHR",
  //     pt_postal_code_shipping: "00973", //Put Country Phone code if Postal
  //     pt_color: "#cccccc",
  //     pt_language: 'en', // 'en', 'ar'
  //     pt_tokenization: true,
  //     pt_preauth: false
  //   };
  //   FlutterPaytabsSdk.startPayment(args, (event) {
  //     setState(() {
  //       print(event);
  //       List<dynamic> eventList = event;
  //       Map firstEvent = eventList.first;
  //       if (firstEvent.keys.first == "EventPreparePaypage") {
  //         //_result = firstEvent.values.first.toString();
  //       } else {
  //         _result = 'Response code:' +
  //             firstEvent["pt_response_code"] +
  //             '\nTransaction ID:' +
  //             firstEvent["pt_transaction_id"] +
  //             '\nResult message:' +
  //             firstEvent["pt_result"];
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    list = new PaymentMethodList(context);
    if (!setting.value.payPalEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "paypal";
      });
    if (!setting.value.razorPayEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "razorpay";
      });
    if (!setting.value.stripeEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "visacard" || element.id == "mastercard";
      });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).payment_mode,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(),
            ),
            SizedBox(height: 15),
            list.paymentsList.length > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      trailing: Icon(
                        Icons.payment,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).payment_options,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                          S.of(context).select_your_preferred_payment_mode),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            SizedBox(height: 10),
            // ListView.separated(
            //   scrollDirection: Axis.vertical,
            //   shrinkWrap: true,
            //   primary: false,
            //   itemCount: list.paymentsList.length,
            //   separatorBuilder: (context, index) {
            //     return SizedBox(height: 10);
            //   },
            //   itemBuilder: (context, index) {
            //     return PaymentMethodListItemWidget(
            //         paymentMethod: list.paymentsList.elementAt(index));
            //   },
            // ),
            // SizedBox(height: 10),

            // list.cashList.length > 0
            //     ? Padding(
            //         padding: const EdgeInsets.symmetric(
            //             vertical: 10, horizontal: 20),
            //         child: ListTile(
            //           contentPadding: EdgeInsets.symmetric(vertical: 0),
            //           leading: Icon(
            //             Icons.monetization_on,
            //             color: Theme.of(context).hintColor,
            //           ),
            //           title: Text(
            //             S.of(context).cash_on_delivery,
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //             style: Theme.of(context).textTheme.headline4,
            //           ),
            //           subtitle: Text(
            //               S.of(context).select_your_preferred_payment_mode),
            //         ),
            //       )
            //     : SizedBox(
            //         height: 0,
            //       ),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: list.cashList.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return PaymentMethodListItemWidget(
                    paymentMethod: list.cashList.elementAt(index));
              },
            ),
            // FlatButton(
            //   onPressed: () {
            //     payPressed();
            //   },
            //   color: Colors.blue,
            //   textColor: Colors.white,
            //   child: Text('Pay with PayTabs'),
            // ),
          ],
        ),
      ),
    );
  }
}
