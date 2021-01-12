import 'package:markets/src/models/market.dart';
import 'package:markets/src/models/product.dart';

class RouteArgument {
  String id;
  String heroTag;
  dynamic param;
  Market marketData;
  Product product;

  RouteArgument({this.id, this.heroTag, this.param, this.marketData, this.product});

  @override
  String toString() {
    return '{id: $id, heroTag:${heroTag.toString()}, marketData:$marketData, product:$product}';
  }
}
