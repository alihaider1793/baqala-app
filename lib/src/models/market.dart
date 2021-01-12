import '../models/media.dart';

class Market {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  String latitude;
  String longitude;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  double deliveryRange;
  double distance;
  double deliveryTime;
  double min_order_amount;
  bool specialOffer;
  bool closed;
  bool availableForDelivery;

  Market();

  Market.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      // print('testtt');
      // print(jsonMap);
      // print("market min order amount");
      // print(jsonMap['min_order_amount'].runtimeType);
      // print(jsonMap['min_order_amount'].toString().isEmpty);
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Media.fromJSON(jsonMap['media'][0])
          : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null
          ? jsonMap['delivery_fee'].toDouble()
          : 0.0;

      specialOffer = jsonMap['special_offer'] == 1 ? true : false;
      min_order_amount = jsonMap.containsKey("min_order_amount") &&
              jsonMap['min_order_amount'] != null &&
              jsonMap['min_order_amount'].toString().isNotEmpty
          ? double.parse(jsonMap['min_order_amount'].toString())
          : 0.0;

      print("min done");
      adminCommission = jsonMap['admin_commission'] != null
          ? jsonMap['admin_commission'].toDouble()
          : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null
          ? jsonMap['delivery_range'].toDouble()
          : 0.0;
      // print('delivery rangee: ' + deliveryRange.toString());
      address = jsonMap['address'];
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null
          ? jsonMap['default_tax'].toDouble()
          : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = jsonMap['closed'] ?? false;
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      distance = jsonMap['distance'] != null
          ? double.parse(jsonMap['distance'].toString())
          : 0.0;

//      deliveryTime = jsonMap['delivery_time'] == 0 ? 0 : double.parse(jsonMap['delivery_time'].toString());

      deliveryTime =
          jsonMap['delivery_time'] == 0 || jsonMap['delivery_time'] == null
              ? 0.0
              : 0.0;

      calculateDeliverTime(rate, deliveryTime);
      // : double.parse(jsonMap['delivery_time'].toString());
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      min_order_amount = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      availableForDelivery = false;
      distance = 0.0;
      deliveryTime = 0;
      print(e);
    }
  }

  double calculateDeliverTime(rate, deliveryTime) {
    if (rate == '0') {
      // print("testt123");
      if (deliveryTime > 0)
        return deliveryTime;
      else
        return 0;
    } else {
      double x = double.tryParse(rate.split('.')[0].substring(0, 1));
      double y = double.tryParse(rate.split('.')[1].substring(0, 1));
      if (x == 1) {
        if (y == 1) return 75 - (1.5 * y);
        if (y == 2) return 75 - (1.5 * y);
        if (y == 3) return 75 - (1.5 * y);
        if (y == 4) return 75 - (1.5 * y);
        if (y == 5) return 75 - (1.5 * y);
        if (y == 6) return 75 - (1.5 * y);
        if (y == 7) return 75 - (1.5 * y);
        if (y == 8) return 75 - (1.5 * y);
        if (y == 9) return 75 - (1.5 * y);
      }
      if (x == 2) {
        if (y == 1) return 60 - (1.5 * y);
        if (y == 2) return 60 - (1.5 * y);
        if (y == 3) return 60 - (1.5 * y);
        if (y == 4) return 60 - (1.5 * y);
        if (y == 5) return 60 - (1.5 * y);
        if (y == 6) return 60 - (1.5 * y);
        if (y == 7) return 60 - (1.5 * y);
        if (y == 8) return 60 - (1.5 * y);
        if (y == 9) return 60 - (1.5 * y);
      }
      if (x == 3) {
        if (y == 1) return 45 - (1.5 * y);
        if (y == 2) return 45 - (1.5 * y);
        if (y == 3) return 45 - (1.5 * y);
        if (y == 4) return 45 - (1.5 * y);
        if (y == 5) return 45 - (1.5 * y);
        if (y == 6) return 45 - (1.5 * y);
        if (y == 7) return 45 - (1.5 * y);
        if (y == 8) return 45 - (1.5 * y);
        if (y == 9) return 45 - (1.5 * y);
      }
      if (x == 4) {
        if (y == 1) return 30 - (1.5 * y);
        if (y == 2) return 30 - (1.5 * y);
        if (y == 3) return 30 - (1.5 * y);
        if (y == 4) return 30 - (1.5 * y);
        if (y == 5) return 30 - (1.5 * y);
        if (y == 6) return 30 - (1.5 * y);
        if (y == 7) return 30 - (1.5 * y);
        if (y == 8) return 30 - (1.5 * y);
        if (y == 9) return 30 - (1.5 * y);
      }
      if (x == 5) {
        if (y == 1) return 15 - (1.5 * y);
        if (y == 2) return 15 - (1.5 * y);
        if (y == 3) return 15 - (1.5 * y);
        if (y == 4) return 15 - (1.5 * y);
        if (y == 5) return 15 - (1.5 * y);
        if (y == 6) return 15 - (1.5 * y);
        if (y == 7) return 15 - (1.5 * y);
        if (y == 8) return 15 - (1.5 * y);
        if (y == 9) return 15 - (1.5 * y);
      }
    }
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
      'delivery_time': deliveryTime
    };
  }
}
