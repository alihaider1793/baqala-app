import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import '../controllers/category_controller.dart';
import '../pages/menu_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/favorite.dart';
import '../models/filter.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Product>> getTrendingProducts(Address address) async {
  Uri uri = Helper.getUri('api/products');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter =
      Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  filter.delivery = false;
  filter.open = false;
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> getProduct(String productId) async {
  // print('gettingproduct ' + productId);
  Uri uri = Helper.getUri('api/products/$productId');
  uri = uri.replace(queryParameters: {
    'with':
        'market;category;options;optionGroups;productReviews;productReviews.user'
  });
  print(uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> searchProducts(String search, Address address) async {
  DateTime currentDateTime = new DateTime.now();
  print('${currentDateTime.hour.toString()}:${currentDateTime.minute.toString()}');
  Uri uri = Helper.getUri('api/products');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = 'name:$search;description:$search';
  _queryParams['searchFields'] = 'name:like;description:like';
  _queryParams['limit'] = '5';
  _queryParams['take'] = '30';
  _queryParams['skip'] = '0';
  _queryParams['time'] = '${currentDateTime.hour.toString()}:${currentDateTime.minute.toString()}';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: _queryParams);
  print('searching for products in repoo: ' + uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> getProductsByCategory(int skip, int take, categoryId) async
{
  DateTime currentDateTime = new DateTime.now();

  getProductsByCategoryCount(skip, take, categoryId);
  // print('getting products by category: ' + categoryId);
  Uri uri = Helper.getUri('api/products');
  // print('uri: ' + uri.toString());
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['with'] = 'market';
  _queryParams['search'] = 'category_id:$categoryId';
  _queryParams['searchFields'] = 'category_id:=';

  // print('_queryParams: ' + _queryParams.toString());

  _queryParams = filter.toQuery(oldQuery: _queryParams);
  _queryParams['skip'] = '' + skip.toString();
  _queryParams['take'] = '' + take.toString();
  _queryParams['time'] = '${currentDateTime.hour.toString()}:${currentDateTime.minute.toString()}';
  // print('_queryParams: ' + _queryParams.toString());

  uri = uri.replace(queryParameters: _queryParams);
  print('uriii: ' + uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      print("returning success");
      return Product.fromJSON(data);
    });
  } catch (e) {
    print("returning error");
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<void> getProductsByCategoryCount(int skip, int take, categoryId) async {
  CategoryController.totalCategoryProducts = 0;
  CategoryController.noProducts = true;
  Uri uri = Helper.getUri('api/getProductSearchTotal');
  final client = new http.Client();
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter =
      Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['with'] = 'market';
  _queryParams['search'] = 'category_id:$categoryId';
  _queryParams['searchFields'] = 'category_id:=';

  _queryParams = filter.toQuery(oldQuery: _queryParams);
  _queryParams['skip'] = '' + skip.toString();
  _queryParams['take'] = '' + take.toString();

  uri = uri.replace(queryParameters: _queryParams);
  final response = await client.send(http.Request('get', uri));
  final respStr = await response.stream.bytesToString();
  String b = respStr.substring(0, respStr.length - 1);
  String c = b.substring(1, b.length);
  CategoryController.totalCategoryProducts = int.parse(c);
  if (CategoryController.totalCategoryProducts == 0) {
    CategoryController.noProducts = true;
  } else {
    CategoryController.noProducts = false;
  }
  print('total search products of category!');
  print(CategoryController.totalCategoryProducts.toString());
}

Future<Stream<Favorite>> isFavoriteProduct(String productId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites/exist?${_apiToken}product_id=$productId&user_id=${_user.id}';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getObjectData(data))
        .map((data) => Favorite.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

Future<Stream<Favorite>> getFavorites() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites?${_apiToken}with=product;product.market;user;options&search=user_id:${_user.id}&searchFields=user_id:=';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  print("getting favourite products: $url");
  try {
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
          print(data);
          return Favorite.fromJSON(data);
        });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

Future<Favorite> addFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  favorite.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites?$_apiToken';
  try {
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      },
      body: json.encode(favorite.toMap()),
    );
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

Future<Favorite> removeFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites/${favorite.id}?$_apiToken';
  try {
    final client = new http.Client();
    final response = await client.delete(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      },
    );
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

Future<Stream<Product>> getProductsOfMarket(int skip, int take, String marketId,
    {List<String> categories}) async
{

  getProductsOfMarketCount(skip, take, marketId);

  Uri uri = Helper.getUri('api/products/categories');

  Map<String, dynamic> query = {
    'with': 'market;category;options;productReviews',
    'search': 'market_id:$marketId',
    'searchFields': 'market_id:=',
    'skip': '' + skip.toString(),
    'take': '' + take.toString()
  };

  if (categories != null && categories.isNotEmpty) {
    query['categories[]'] = categories;
  }
  uri = uri.replace(queryParameters: query);
  print('getting market products: ' + uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    print(uri.toString());

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
          print("returning data");
      return Product.fromJSON(data);
    });
  } catch (e) {
    print("error caught");
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

// if market has special offers then it must has discounted products as well
Future<Stream<Product>> getDiscountedProductsOfMarket(int skip, int take, String marketId,
    {List<String> categories}) async {
  getProductsOfMarketCount(skip, take, marketId);
  Uri uri = Helper.getUri('api/specialOffers');
  Map<String, dynamic> query = {
    'with': 'market;category;options;productReviews',
    'search': 'market_id:$marketId',
    'searchFields': 'market_id:=',
    'skip': '' + skip.toString(),
    'take': '' + take.toString()
  };

  // if (categories != null && categories.isNotEmpty) {
  //   query['categories[]'] = categories;
  // }
  uri = uri.replace(queryParameters: query);
  print('getting market products: ' + uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    print(uri.toString());

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
          print("discounted products");
      print(data);
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> searchProducts1(String search, Address address) async {
  Uri uri = Helper.getUri('api/products/searchMarket');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = 'name:$search;description:$search';
  _queryParams['searchFields'] = 'name:like;description:like';
  _queryParams['searchStr'] = search;
  _queryParams['marketID'] = MenuWidget.openedMarket;
  _queryParams['limit'] = '5';
  _queryParams['take'] = '100';
  _queryParams['skip'] = '0';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }

  uri = uri.replace(queryParameters: _queryParams);
  print('inside search custom: ' + uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    print(uri.toString());

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
          print(data);
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<void> getProductsOfMarketCount(int skip, int take, String marketId,
    {List<String> categories}) async {
  Uri uri = Helper.getUri('api/getProductCategorySearchTotal');
  Map<String, dynamic> query = {
    'with': 'market;category;options;productReviews',
    'search': 'market_id:$marketId',
    'searchFields': 'market_id:=',
    'skip': '' + skip.toString(),
    'take': '' + take.toString()
  };

  if (categories != null && categories.isNotEmpty) {
    query['categories[]'] = categories;
  }
  uri = uri.replace(queryParameters: query);
  print('getting market products: ' + uri.toString());
  try {
    final client = new http.Client();
    final response = await client.send(http.Request('get', uri));
    final respStr = await response.stream.bytesToString();
    String b = respStr.substring(0, respStr.length - 1);
    String c = b.substring(1, b.length);
    CategoryController.totalMarketProducts = int.parse(c);
    print('total search products of market!');
    print(CategoryController.totalMarketProducts.toString());
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> getTrendingProductsOfMarket(String marketId) async {
  Uri uri = Helper.getUri('api/products');
  uri = uri.replace(queryParameters: {
    'with': 'category;options;productReviews',
    'search': 'market_id:$marketId;featured:1',
    'searchFields': 'market_id:=;featured:=',
    'searchJoin': 'and',
    'skip': '0',
    'take': '10'
  });

  print('getting trending products! ' + uri.toString());
  // TODO Trending products only
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> getFeaturedProductsOfMarket(
    int skip, int take, String marketId) async {
  getFeaturedProductsOfMarketCount(skip, take, marketId);
  Uri uri = Helper.getUri('api/products');
  uri = uri.replace(queryParameters: {
    'with': 'category;options;productReviews',
    'search': 'market_id:$marketId;featured:1',
    'searchFields': 'market_id:=;featured:=',
    'searchJoin': 'and',
    'skip': '' + skip.toString(),
    'take': '' + take.toString()
  });
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<void> getFeaturedProductsOfMarketCount(
    int skip, int take, String marketId) async {
  CategoryController.totalCategoryProducts = 0;
  CategoryController.noProducts = true;
  Uri uri = Helper.getUri('api/getProductSearchTotal');
  uri = uri.replace(queryParameters: {
    'with': 'category;options;productReviews',
    'search': 'market_id:$marketId;featured:1',
    'searchFields': 'market_id:=;featured:=',
    'searchJoin': 'and',
    'skip': '' + skip.toString(),
    'take': '' + take.toString()
  });
  try {
    final client = new http.Client();
    final response = await client.send(http.Request('get', uri));
    final respStr = await response.stream.bytesToString();
    String b = respStr.substring(0, respStr.length - 1);
    String c = b.substring(1, b.length);
    CategoryController.totalCategoryProducts = int.parse(c);
    if (CategoryController.totalCategoryProducts == 0) {
      CategoryController.noProducts = true;
    } else {
      CategoryController.noProducts = false;
    }
    print('total featured products of market!');
    print(CategoryController.totalCategoryProducts.toString());
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Review> addProductReview(Review review, Product product) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}product_reviews';
  final client = new http.Client();
  review.user = userRepo.currentUser.value;
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      },
      body: json.encode(review.ofProductToMap(product)),
    );
    if (response.statusCode == 200) {
      return Review.fromJSON(json.decode(response.body)['data']);
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
      return Review.fromJSON({});
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Review.fromJSON({});
  }
}
