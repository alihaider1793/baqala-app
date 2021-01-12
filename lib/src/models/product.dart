import '../models/category.dart';
import '../models/market.dart';
import '../models/media.dart';
import '../models/option.dart';
import '../models/option_group.dart';
import '../models/review.dart';

class Product {
  String id;
  String name;
  double price;
  double priceForGLView;
  double discountPriceForGLView;
  double discountPrice;
  Media image;
  String description;
  String ingredients;
  String capacity;
  String unit;
  String packageItemsCount;
  bool featured;
  bool deliverable;
  String marketId;
  Market market;
  Category category;
  List<Option> options;
  List<OptionGroup> optionGroups;
  List<Review> productReviews;

  Product();

  Product.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      marketId = jsonMap['market_id'].toString();
      name = jsonMap['name'];
      print(name);
      market = jsonMap['market'] != null
          ? Market.fromJSON(jsonMap['market'])
          : Market.fromJSON({});

      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      priceForGLView =
          jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      discountPrice = jsonMap['discount_price'] != null
          ? jsonMap['discount_price'].toDouble()
          : 0.0;
      discountPriceForGLView = jsonMap['discount_price'] != null
          ? jsonMap['discount_price'].toDouble()
          : 0.0;
      price = discountPrice != 0 ? discountPrice : price;
      discountPrice = discountPrice == 0
          ? discountPrice
          : jsonMap['price'] != null
              ? jsonMap['price'].toDouble()
              : 0.0;

      description = jsonMap['description'];
      capacity = jsonMap['capacity'].toString();
      unit = jsonMap['unit'] != null ? jsonMap['unit'].toString() : '';
      packageItemsCount = jsonMap['package_items_count'].toString();
      featured = jsonMap['featured'] ?? false;
      deliverable = jsonMap['deliverable'] ?? false;
      // print('market from product: ' + market.name);
      // print('market from product delivery range: ' +
      //     market.deliveryRange.toString());
      category = jsonMap['category'] != null
          ? Category.fromJSON(jsonMap['category'])
          : Category.fromJSON({});
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Media.fromJSON(jsonMap['media'][0])
          : new Media();
      options =
          jsonMap['options'] != null && (jsonMap['options'] as List).length > 0
              ? List.from(jsonMap['options'])
                  .map((element) => Option.fromJSON(element))
                  .toSet()
                  .toList()
              : [];
      optionGroups = jsonMap['option_groups'] != null &&
              (jsonMap['option_groups'] as List).length > 0
          ? List.from(jsonMap['option_groups'])
              .map((element) => OptionGroup.fromJSON(element))
              .toSet()
              .toList()
          : [];
      productReviews = jsonMap['product_reviews'] != null &&
              (jsonMap['product_reviews'] as List).length > 0
          ? List.from(jsonMap['product_reviews'])
              .map((element) => Review.fromJSON(element))
              .toSet()
              .toList()
          : [];

      print("done product");
    } catch (e) {
      marketId = '';
      id = '';
      name = '';
      price = 0.0;
      discountPrice = 0.0;
      priceForGLView = 0.0;
      discountPriceForGLView = 0.0;
      description = '';
      capacity = '';
      unit = '';
      packageItemsCount = '';
      featured = false;
      deliverable = false;
      market = Market.fromJSON({});
      category = Category.fromJSON({});
      image = new Media();
      options = [];
      optionGroups = [];
      productReviews = [];
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["market_id"] = marketId;
    map["name"] = name;
    map["price"] = price;
    map["discountPrice"] = discountPrice;
    map["description"] = description;
    map["capacity"] = capacity;
    map["package_items_count"] = packageItemsCount;
    return map;
  }

  double getRate() {
    double _rate = 0;
    productReviews.forEach((e) => _rate += double.parse(e.rate));
    _rate = _rate > 0 ? (_rate / productReviews.length) : 0;
    return _rate;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
