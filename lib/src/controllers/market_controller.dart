import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/category.dart';
import '../models/gallery.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';

class MarketController extends ControllerMVC {
  Market market;
  List<Gallery> galleries = <Gallery>[];
  List<Product> products = <Product>[];
  List<Category> categories = <Category>[];
  List<Product> trendingProducts = <Product>[];
  List<Product> featuredProducts = <Product>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  List<Cart> carts = [];
  bool loadCart = false;
  bool doneFetchingProducts = false;

  MarketController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForMarket({String id, String message}) async {
    final Stream<Market> stream = await getMarket(id, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => market = _market);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForGalleries(String idMarket) async {
    final Stream<Gallery> stream = await getGalleries(idMarket);
    stream.listen((Gallery _gallery) {
      setState(() => galleries.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForMarketReviews({String id, String message}) async {
    final Stream<Review> stream = await getMarketReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForProducts(int skip, int take, String idMarket,
      {List<String> categoriesId}) async {
    print("fetching products");
    doneFetchingProducts = false;
    final Stream<Product> stream = await getProductsOfMarket(
        skip, take, idMarket,
        categories: categoriesId);
    stream.listen((Product _product) {
      setState(() {
        products.add(_product);
      });
    }, onError: (a) {
      print("error caught");
      print(a);
    }, onDone: () {
      if(products.isNotEmpty && products != null)
        {
          // market..name = products.elementAt(0)?.market?.name;
          market..name = products.elementAt(0).market?.name;
        }
      setState((){
        doneFetchingProducts = true;
      });
    });
  }

  void listenForDiscountedProducts(int skip, int take, String idMarket,
      {List<String> categoriesId}) async {
    products.clear();
    doneFetchingProducts = false;
    final Stream<Product> stream = await getDiscountedProductsOfMarket(
        skip, take, idMarket,
        categories: categoriesId);
    stream.listen((Product _product) {
      setState(() {
        products.add(_product);
      });
    }, onError: (a) {
      print("error caught");
      print(a);
    }, onDone: () {
      // market..name = products.elementAt(0)?.market?.name;
      setState((){
        doneFetchingProducts = true;
      });
    });
  }

  Future<void> selectCategory(List<String> categoriesId) async {
    products.clear();
    listenForProducts(0, 10, market.id, categoriesId: categoriesId);
  }

  Future<void> listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameMarkets(Product product) {
    if (carts.isNotEmpty) {
      print('inside market controller isSame: ' +
          (carts[0].product?.market?.id == product.market?.id).toString());
      return carts[0].product?.market?.id == product.market?.id;
    }
    return true;
  }

  void addToCart(Product product, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options = [];
    _newCart.quantity = 1;
    // if product exist in the cart then increment quantity
    var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {
      _oldCart.quantity++;
      updateCart(_oldCart).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_product_was_added_to_cart),
        ));
      });
    } else {
      // the product doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        listenForCart().then((value) => {
              scaffoldKey?.currentState?.showSnackBar(SnackBar(
                content: Text(S.of(context).this_product_was_added_to_cart),
              )),
            });
      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart),
        orElse: () => null);
  }

  void listenForTrendingProducts(String idMarket) async {
    print('listenForTrendingProducts: ' + idMarket);
    final Stream<Product> stream = await getTrendingProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedProducts(int skip, int take, String idMarket) async {
    final Stream<Product> stream =
        await getFeaturedProductsOfMarket(skip, take, idMarket);
    stream.listen((Product _product) {
      setState(() => featuredProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      print(categories[0]);
      // categories.insert(0, new Category.fromJSON({'id': '0', 'name': 'Offers'}));
      categories.insert(
          0, new Category.fromJSON({'id': '0', 'name': S.of(context).all}));
    });
  }

  Future<void> listenForMarketCategories(String _marketId) async {
    final Stream<Category> stream = await getMarketCategories(_marketId);
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      // categories.insert(0, new Category.fromJSON({'id': '0', 'name': 'Offers'}));
      categories.insert(
          0, new Category.fromJSON({'id': '0', 'name': S.of(context).all}));
    });
  }

  Future<void> refreshMarket() async {
    var _id = market.id;
    market = new Market();
    galleries.clear();
    reviews.clear();
    featuredProducts.clear();
    listenForMarket(
        id: _id, message: S.of(context).market_refreshed_successfuly);
    listenForMarketReviews(id: _id);
    listenForGalleries(_id);
    listenForFeaturedProducts(0, 10, _id);
  }
}
