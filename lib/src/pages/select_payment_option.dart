import 'package:flutter/material.dart';
import 'package:markets/src/controllers/cart_controller.dart';
import 'package:markets/src/controllers/checkout_controller.dart';
import 'package:markets/src/elements/PaymentCardDetailsWidget.dart';
import 'package:markets/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SelectPaymentOption extends StatefulWidget {
  final RouteArgument routeArgument;
  SelectPaymentOption({this.routeArgument});
  @override
  _SelectPaymentOptionState createState() => _SelectPaymentOptionState();
}

class _SelectPaymentOptionState extends StateMVC<SelectPaymentOption> {
  CheckoutController _con;

  _SelectPaymentOptionState() : super(CheckoutController()) {
    _con = controller;
  }

  double invoiceAmount;

  @override
  void initState() {
    // TODO: implement initState
    invoiceAmount = CartController.totalBill;
    _con.initiatePaymentMethodsList(invoiceAmount);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Payment Option",
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: _con.paymentMethods.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
              scrollDirection: Axis.vertical,
              itemCount: _con.paymentMethods.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 3.5);
              },
              itemBuilder: (context, index) {
                return PaymentCardDetailsWidget(invoiceValue: invoiceAmount, paymentMethod: _con.paymentMethods[index], paymentMethodIdFunc: (int id, double totalPayable) {
                  print(id);
                  _con.executeRegularPayment(context: context, methodId: id.toString(), invoiceValue: totalPayable.toString());
                });
              },
      ),
    );
  }
}
