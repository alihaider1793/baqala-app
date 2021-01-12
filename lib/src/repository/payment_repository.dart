import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

Future<List<PaymentMethods>> initiatePayment2(double amount) async{
  var request = new MFInitiatePaymentRequest(amount, MFCurrencyISO.UAE_AED);

  List<PaymentMethods> paymentMethods;

  await MFSDK.initiatePayment(
      request,
      MFAPILanguage.EN,
      (MFResult<MFInitiatePaymentResponse> result) async
      {
        if (result.isSuccess())
          {
              print(result.response.toJson());
              paymentMethods = await result.response.paymentMethods;
              // return PaymentMethods.fromJson(result.response.toJson());

          }
        else
          {
            print(result.error.toJson());
            // return PaymentMethods.fromJson({});

          }
      });
  print("printing payment methods list from repo");
  print(paymentMethods);
  return paymentMethods;

}
