import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/filter.dart';

Future<Stream<Category>> getCategories({String id}) async {
  print("getting categories");
  Uri uri = Helper.getUri('api/categories');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter =
      Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  filter.delivery = false;
  filter.open = false;

  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    print('URI for categories: ' + uri.toString());

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
          // print("printing market data");
          // print(data);
          return Category.fromJSON(data);
    });
  }
  // on SocketException {
  //   print("Socket Exception occured: ");
  //   throw SocketException("Socket exception");
  // }
  catch (e) {
    print("throwing exception");
    // throw e;
    print("error caught");
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Category.fromJSON({}));
  }
}

Future<Stream<Category>> getMarketCategories(String _id) async {
  Uri uri = Helper.getUri('api/categoriesAndProducts');
  Map<String, dynamic> _queryParams = {
    "marketId" : _id
  };
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter =
  Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  filter.delivery = false;
  filter.open = false;

  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    print(uri.toString());
    print(_queryParams);

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      // print(data);
      return Category.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Category.fromJSON({}));
  }
}

Future<Stream<Category>> getCategory(String id) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}categories/$id';
  print('getting category products: ' + url);

  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) {
      print(data);
      return Helper.getData(data);
    }).map((data) {
      print(data);
      return Category.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Category.fromJSON({}));
  }
}
