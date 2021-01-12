import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../models/cart.dart';
import '../helpers/helper.dart';
import '../repository/user_repository.dart';
import '../controllers/cart_controller.dart';

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class CartBottomDetailsWidget extends StatefulWidget {
  final CartController _con;

  const CartBottomDetailsWidget({Key key, @required CartController con,})  : _con = con, super(key: key);

  @override
  _CartBottomDetailsWidgetState createState() =>
      _CartBottomDetailsWidgetState();
}

class _CartBottomDetailsWidgetState extends State<CartBottomDetailsWidget> {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  String _message = "";

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _sendAnalyticsEvent() async {
    print("Analytics: inside func");
    var buffer = new StringBuffer();
//    List<Cart> cartItems = await widget._con.carts;
    for (int i = 0; i < widget._con.carts.length; i++) {
      buffer.write(widget._con.carts[i].product.name);
      buffer.write(",");
    }
//    print(buffer.toString());

    await analytics.logEvent(
      name: 'checkout_analysis',
      parameters: <String, dynamic>{
        'storeName': widget._con.carts[0].product.market.name,
        'userEmail': currentUser.value.email,
        'totalBill': widget._con.total,
        'items': buffer.toString(),
      },
    );
    setMessage('logEvent succeeded');
    print(widget._con.carts[0].product.market.name);
    print(widget._con.carts[0].product.name);
    print(widget._con.carts.runtimeType);
    print("end");
  }

  @override
  Widget build(BuildContext context) {
    return widget._con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: 200,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.15),
                      offset: Offset(0, -2),
                      blurRadius: 5.0)
                ]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(widget._con.subTotal, context,
                          style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 5),
                  //TESTT HIDE DELIVERY FEE
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Text(
                  //         S.of(context).delivery_fee,
                  //         style: Theme.of(context).textTheme.bodyText1,
                  //       ),
                  //     ),
                  //     if (Helper.canDelivery(_con.carts[0].product.market,
                  //         carts: _con.carts))
                  //       Helper.getPrice(
                  //           _con.carts[0].product.market.deliveryFee, context,
                  //           style: Theme.of(context).textTheme.subtitle1)
                  //     else
                  //       Helper.getPrice(0, context,
                  //           style: Theme.of(context).textTheme.subtitle1)
                  //   ],
                  // ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${S.of(context).tax} (${widget._con.carts[0].product.market.defaultTax}%)',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(widget._con.taxAmount, context,
                          style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Service Fee: ',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(widget._con.serviceFeeAmount, context,
                          style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 10),
                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: FlatButton(
                          onPressed: () {
                            _sendAnalyticsEvent();
                            if (widget._con.total >=
                                widget._con.carts[0].product.market
                                    .min_order_amount) {
                              widget._con.goCheckout(context);
                            } else {
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "ALERT",
                                desc:
                                    "Your total bill must be AED ${widget._con.carts[0].product.market.min_order_amount} or more to continue!",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Ok",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    width: 120,
                                  )
                                ],
                              ).show();
                            }
                          },
                          disabledColor:
                              Theme.of(context).focusColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          color: !widget._con.carts[0].product.market.closed
                              ? Theme.of(context).accentColor
                              : Theme.of(context).focusColor.withOpacity(0.5),
                          shape: StadiumBorder(),
                          child: Text(
                            S.of(context).checkout,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Helper.getPrice(
                          widget._con.total,
                          context,
                          style: Theme.of(context).textTheme.headline4.merge(
                              TextStyle(color: Theme.of(context).primaryColor)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
