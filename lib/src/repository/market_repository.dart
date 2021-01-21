import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/filter.dart';
import '../models/market.dart';
import '../models/review.dart';
import '../repository/user_repository.dart';

Future<Stream<Market>> getNearMarkets(
    Address myLocation, Address areaLocation, int skip, int take) async {
  Uri uri = Helper.getUri('api/markets');
  print('API FOR GETTTING MARKET DATA: ' + uri.toString());
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter =
      Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['limit'] = take.toString();
  _queryParams['skip'] = skip.toString();
  if (!myLocation.isUnknown() && !areaLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();
    _queryParams['areaLon'] = areaLocation.longitude.toString();
    _queryParams['areaLat'] = areaLocation.latitude.toString();
  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  print('API FOR GETTTING MARKET DATA1: ' + uri.toString());

  try {
    final client = new http.Client();
    print("my uri for markets: $uri");
    final streamedRest = await client.send(http.Request('get', uri));
    final streamedRest1 = await http.get(uri.toString());

    print("streamedRest: ${streamedRest1.body}");

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) {
      print("data: $data");
      return Helper.getData(data);
    }).expand((data) {
      print("data as list: ${data as List}");
      return (data as List);
    }).map((data) {
      // print('MARKET DATAAA: ');
      // print(Market.fromJSON(data).deliveryRange);
      print("data again: $data");
      print("amount");
      print(data['min_order_amount']);
      return Market.fromJSON(data);
    });
  }
  // on SocketException {
  //   print("Socket Exception occured: ");
  //   throw SocketException("Socket Exception");
  // }
  catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Market>> getPopularMarkets(Address myLocation) async {
  Uri uri = Helper.getUri('api/markets');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter =
      Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  _queryParams['limit'] = '6';
  _queryParams['popular'] = 'all';
  if (!myLocation.isUnknown()) {
    _queryParams['myLon'] = myLocation.longitude.toString();
    _queryParams['myLat'] = myLocation.latitude.toString();
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
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Market>> searchMarkets(String search, Address address) async {
  Uri uri = Helper.getUri('api/markets');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = 'name:$search';
  _queryParams['searchFields'] = 'name:like;';
  _queryParams['limit'] = '5';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: _queryParams);
  print('searching for markets in repo: ' + uri.toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Market>> getMarket(String id, Address address) async {
  Uri uri = Helper.getUri('api/markets/$id');
  Map<String, dynamic> _queryParams = {};
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .map((data) {
      print("Markets");
      print(data);
      print("amount");
      print(data['min_order_amount']);
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Review>> getMarketReviews(String id) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}market_reviews?with=user&search=market_id:$id';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Review.fromJSON({}));
  }
}

Future<Stream<Review>> getRecentReviews() async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}market_reviews?orderBy=updated_at&sortedBy=desc&limit=3&with=user';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Review.fromJSON({}));
  }
}

Future<Review> addMarketReview(Review review, Market market) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}market_reviews';
  final client = new http.Client();
  review.user = currentUser.value;
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      },
      body: json.encode(review.ofMarketToMap(market)),
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
