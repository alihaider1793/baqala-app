import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html/parser.dart';
import 'package:markets/src/controllers/home_controller.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:markets/src/models/payment_method.dart';
import 'package:markets/src/models/route_argument.dart';
import 'package:markets/src/repository/payment_repository.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class CheckoutController extends CartController {
  Payment payment;
  CreditCard creditCard = new CreditCard();
  bool loading = true;
  List<String> cardExpiryMonthYear = [];
  OverlayEntry loader;

  List<PaymentMethods> paymentMethods = [];
  final String _baseURL = 'https://api.myfatoorah.com';
  final String _apiKey =
      'DVL6_C2Kh-dCmn6OCoYSWzrLGe6YWy2xIdK-tHh0WTvVdXIJlR1_m-_603sv0LhoqEUg2kurf2EUAd2sHZ7pqBez6miL6aSkKnwJGfUhwqJY7BDTj10woos4fSvqipFXgQKi6dzad-QcraobvSsww8QSbipoV2lER6q92DKg6vrWa7SvT3982TyH28_qTvBaKMFbBmeBI4sHdFja2uv6q_GQY4CpjWR_vlaT6v1m4jjoPl8J-gUO_pSbkAyPjNWTEOP-xUgs71d_kiAt_NT_WKo996Kp5Iw0AdrbGrysayZn0I20KDlErdF3HPSf2PzpKpsiaMc72u0UZhR0NYNlTqruNMB74CKDsil8kTSiJoK1gdNZ5GXTc7g4X0Wjl6EIqrVTaCMhMfaZYc7F03xytaazmvIRp2kfaDg7roE2D1MnyP0ntcrGPKxf5wrZmY4Bz0MdZUkl5rbIiWTF6ytFI2lmsguKDQGCmQ1K_IzRnYwvojpociPBMxPqGq39azYm4LnpnY53uAzw34CnaWCwDVMR6UwKhL2Vd5v-k7x9AFI8iarL_7L1pX5Zj6YpO_1YHU7WS8kfWaWTVVWm-8U2AaoNixpYKO8uradFAR1atOksZ5K0g0pmtO4JpusbwQgPO5c8T4fV-RY_tQ2FnLc-gxSe8dNlZcsitM2xJq0u4Fg0hXK8';

  CheckoutController() {
    MFSDK.init(_baseURL, _apiKey);
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    loader = Helper.overlayLoader(context);
    MFSDK.setUpAppBar(
      isShowAppBar: true,
    );
    // listenForCreditCard();
  }

  void initiatePaymentMethodsList(double amount) async{
    print(amount);

    var request = new MFInitiatePaymentRequest(amount, MFCurrencyISO.UAE_AED);

      await MFSDK.initiatePayment(
          request,
          MFAPILanguage.EN,
              (MFResult<MFInitiatePaymentResponse> result)
          {
            if (result.isSuccess())
              {
                  print(result.response.toJson());
                  setState((){
                    paymentMethods.addAll(result.response.paymentMethods);
                  });

              }
            else
              {
                  print(result.error.toJson());
              }
          });
  }

  void executeDirectPayment({String cardNumber,
    String expiryDate,
    String cvc,
    String holderName}) async
  {
    print(expiryDate);
    // The value "2" is the paymentMethodId of Visa/Master payment method.
    // You should call the "initiatePayment" API to can get this id and the ids of all other payment methods
    String paymentMethod = "6";
    cardExpiryMonthYear = expiryDate.split('/');
    print(cardExpiryMonthYear);

    var request = new MFExecutePaymentRequest(paymentMethod, "10.0");

    var mfCardInfo = new MFCardInfo(
        cardNumber: cardNumber,
        expiryMonth: cardExpiryMonthYear[0],
        expiryYear: cardExpiryMonthYear[1],
        securityCode: cvc,
        cardHolderName: holderName,
        saveToken: true);

    await MFSDK.executeDirectPayment(
        context,
        request,
        mfCardInfo,
        MFAPILanguage.EN,
            (String invoiceId, MFResult<MFDirectPaymentResponse> result) {
          print(result.status);
          if (result.isSuccess())
          {
            print("in success");
            print(invoiceId);
            print(result);
            print(result.response.toJson().toString());

          }
          else
          {
            print("in error");
            print(invoiceId.isEmpty);
            print(result);
            print(result.error.toJson().toString());
          }
        });
  }

  /*
    Execute Regular Payment
   */
  void executeRegularPayment({BuildContext context, String methodId, String invoiceValue}) async{
    var request = new MFExecutePaymentRequest(methodId, invoiceValue);

    await MFSDK.executePayment(
        context,
        request,
        MFAPILanguage.EN,
            (String invoiceId, MFResult<MFPaymentStatusResponse> result) {
          if (result.isSuccess())
            {
              print("in success");

                print(invoiceId);
                print(result.response.toJson());
                Map<String,dynamic> data = result.response.toJson();

                if(data.containsKey("InvoiceTransactions"))
                  {
                    List<Map<String,dynamic>> transactions = data['InvoiceTransactions'];
                    if(transactions.isNotEmpty)
                      {
                        if(transactions[0]['TransactionStatus'] != "Failed")
                          {
                            Navigator.of(context).pushReplacementNamed('/OrderSuccess',
                                arguments:
                                new RouteArgument(param: 'Credit Card (MyFatoorah)'));
                          }
                        else
                          {
                            final snackBar = SnackBar(
                              content: Text(
                                'Transaction Failed!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.red[600],
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                      }
                    else
                      {
                        final snackBar = SnackBar(
                          content: Text(
                            'Transaction Failed!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.red[600],
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                  }
                else
                  {
                    final snackBar = SnackBar(
                      content: Text(
                        'Transaction Failed!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.red[600],
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  }



            }
          else
            {
              print("in failure");
                print(invoiceId);
                print(result.error.toJson());

              final snackBar = SnackBar(
                content: Text(
                  'Transaction Failed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red[600],
              );
              Scaffold.of(context).showSnackBar(snackBar);
            }
        });
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  @override
  void onLoadingCartDone() {
    if (payment != null) addOrder(carts);
    super.onLoadingCartDone();
  }

  void addOrder(List<Cart> carts) async {
    Order _order = new Order();
    _order.productOrders = new List<ProductOrder>();
    _order.tax = carts[0].product.market.defaultTax;

//    _order.serviceFee = HomeController.serviceFee;

    _order.deliveryFee = payment.method == 'Pay on Pickup' ? 0
        : carts[0].product.market.deliveryFee;

    OrderStatus _orderStatus = new OrderStatus();
    _orderStatus.id = '1'; // TODO default order status Id
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;
    _order.hint = ' ';

    carts.forEach((_cart) {
      print("in addOrder method");
      ProductOrder _productOrder = new ProductOrder();
      _productOrder.quantity = _cart.quantity;
      print(_cart.product.price);
      _productOrder.price = _cart.product.price;
      _productOrder.product = _cart.product;
      _productOrder.options = _cart.options;
      _order.productOrders.add(_productOrder);
    });

    orderRepo.addOrder(_order, this.payment).then((value) {
      if (value is Order) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }
}
