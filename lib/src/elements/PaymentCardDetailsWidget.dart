import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets/src/controllers/cart_controller.dart';
import 'package:markets/src/controllers/checkout_controller.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:markets/src/models/payment.dart';
import 'package:markets/src/models/route_argument.dart';
import 'package:markets/src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:credit_card/credit_card_form.dart';
import 'package:credit_card/credit_card_model.dart';
import 'package:credit_card/credit_card_widget.dart';
import 'package:credit_card/flutter_credit_card.dart';
import 'package:myfatoorah_flutter/model/initpayment/SDKInitiatePaymentResponse.dart';

class PaymentCardDetailsWidget extends StatefulWidget {
  // final RouteArgument routeArgument;
  PaymentMethods paymentMethod;
  Function paymentMethodIdFunc;
  double invoiceValue;
  PaymentCardDetailsWidget({this.paymentMethod, this.paymentMethodIdFunc,this.invoiceValue});
  @override
  _PaymentCardDetailsWidgetState createState() => _PaymentCardDetailsWidgetState();
}

class _PaymentCardDetailsWidgetState extends StateMVC<PaymentCardDetailsWidget> {
  CheckoutController _con;

  _PaymentCardDetailsWidgetState() : super(CheckoutController()) {
    _con = controller;
  }
  double totalPayable;
  bool isTileSelected;

  @override
  void initState() {
    // TODO: implement initState
    isTileSelected = false;
    // _con.initiatePaymentMethodsList(invoiceAmount);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    totalPayable = widget.invoiceValue + widget.paymentMethod.serviceCharge;
    return ListTile(
      onTap: () {
        widget.paymentMethodIdFunc(widget.paymentMethod.paymentMethodId, totalPayable);
        // widget.paymentMethodIdFunc()
        setState(() {
          isTileSelected = true;
        });
      },
      leading: Container(
        height: 70.0,
        width: 70.0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0,1.0,1.0,1.0),
          child: CachedNetworkImage(
            imageUrl: widget.paymentMethod.imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Text(
        "${widget.paymentMethod.paymentMethodEn}",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold
        ),
      ),
      trailing: Helper.getPrice(
        totalPayable,
        context,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
        )
      ),
      selected: isTileSelected,
      tileColor: Colors.green[300],
      selectedTileColor: Colors.green[200],
    );
  }
}
