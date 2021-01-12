import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
// import 'package:connectivity/connectivity.dart';

class HomeController extends ControllerMVC {
  static double serviceFee;
  static int totalMarkets;

  List<Category> categories = <Category>[];
  List<Market> topMarkets = <Market>[];
  List<Market> popularMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];

  // final Connectivity _connectivity = Connectivity();
  // StreamSubscription<ConnectivityResult> _connectivitySubscription;

  HomeController() {
    listeForServiceFee();
    listenForTotalMarkets();
    listenForTopMarkets(0, 10);
    // listenForTrendingProducts();
    listenForCategories();
    // listenForPopularMarkets();
    // listenForRecentReviews();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   switch (result) {
  //     case ConnectivityResult.wifi:
  //     case ConnectivityResult.mobile:
  //       {
  //         print("hello");
  //         // setState(() => _connectionStatus = result.toString());
  //         break;
  //       }
  //     case ConnectivityResult.none:
  //       {
  //         print("");
  //         break;
  //       }
  //     default:
  //       {
  //         print("default connection state");
  //         // setState(() => _connectionStatus = 'Failed to get connectivity.');
  //       }
  //       break;
  //   }
  // }

  Future<void> listeForServiceFee() async {
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}serviceFee';
    final client = new http.Client();
    final response = await client.get(
      url,
    );
    // print('SERVICE FEEEEEs');
    String test = response.body.toString();
    String b = test.substring(0, test.length - 1);
    String c = b.substring(1, b.length);
    serviceFee = double.parse(c);
    // print(serviceFee);
  }

  Future<void> listenForTotalMarkets() async {
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}getTotalMarkets';
    final client = new http.Client();
    final response = await client.get(
      url,
    );
    // print('SERVICE FEEEEEs');
    String test = response.body.toString();
    String b = test.substring(0, test.length - 1);
    String c = b.substring(1, b.length);
    totalMarkets = int.parse(c);
    print('total markets!');
    print(totalMarkets);
  }

  Future<void> listenForCategories() async {

    final Stream<Category> stream = await getCategories();

    stream.listen((Category _category) {
      setState(() {
        categories.add(_category);
      });
    }, onError: (a) {
      print("error thrown while getting categories");
      print(a);
    }, onDone: () {
      print("done fetching categories");
    });
  }

  Future<void> listenForTopMarkets(int skip, int take) async {
    final Stream<Market> stream = await getNearMarkets(
        deliveryAddress.value, deliveryAddress.value, skip, take);
    // print('stream value: ');
    // print(stream);
    stream.listen(
        (Market _market) {
          setState(() => topMarkets.add(_market));
        },
        onError: (a) {},
        onDone: () {
          print('NEARBY MARKETS LENGTH: ' + topMarkets.length.toString());
          // print('NEARBY MARKETS LENGTH: ' + topMarkets.toString());
          // print('TOP MARKETS 0 NAME: ' + topMarkets[1].name);
          // print('TOP MARKETS 0 DELIVERY RANGE: ' +
          //     topMarkets[1].deliveryRange.toString());
          // print('TOP MARKETS 0 DELIVERY TIME: ' +
          //     topMarkets[1].deliveryTime.toString());
        });
  }

  Future<void> listenForPopularMarkets() async {
    final Stream<Market> stream =
        await getPopularMarkets(deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => popularMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingProducts() async {
    final Stream<Product> stream =
        await getTrendingProducts(deliveryAddress.value);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      if (_address.address == null) {
        requestForCurrentLocation(context);
      }
      print('address without login: ');
      print(_address.address);
      deliveryAddress.value = _address;
      loader.remove();
      await refreshHome();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> refreshHome() async {
    setState(() {
      categories = <Category>[];
      topMarkets = <Market>[];
      popularMarkets = <Market>[];
      recentReviews = <Review>[];
      trendingProducts = <Product>[];
    });
    await listenForTopMarkets(0, 10);
    // await listenForTrendingProducts();
    await listenForCategories();
    // await listenForPopularMarkets();
    // await listenForRecentReviews();
    await listenForTotalMarkets();
  }
}
