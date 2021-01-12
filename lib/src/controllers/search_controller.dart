import '../repository/market_repository.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../pages/menu_list.dart';

import '../repository/cart_repository.dart';
import 'package:flutter/material.dart';
import '../models/cart.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../models/address.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../repository/product_repository.dart';
import '../repository/search_repository.dart';
import '../repository/settings_repository.dart';

class SearchController extends ControllerMVC {
  List<Market> markets = <Market>[];
  List<Product> products = <Product>[];

  List<Cart> carts = [];
  bool loadCart = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  bool doneSearchingProducts = false;
  bool doneSearchingMarkets = false;

  SearchController() {
    print("in search controller constructor");
    // listenForMarkets();
    // listenForProducts();
  }

  Future<void> listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameMarkets(Product product) {
    if (carts.isNotEmpty) {
      print('inside search controller isSame: ' +
          (carts[0].product?.market?.id == product.market?.id).toString());
      print('inside search controller isSame: ' +
          carts[0].product?.market?.id.toString());
      print(
          'inside search controller isSame: ' + product.marketId);
      return carts[0].product?.market?.id ==  product.marketId;
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
        Alert(
          context: context,
          type: AlertType.none,
          title: "",
          desc: "This product was added to cart",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      });
    } else {
      // the product doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        listenForCart().then((value) => {
              Alert(
                context: context,
                type: AlertType.none,
                title: "",
                desc: "This product was added to cart",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Ok",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                    width: 120,
                  )
                ],
              ).show()
            });
      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart),
        orElse: () => null);
  }

  void listenForMarkets({String search}) async {
    doneSearchingMarkets = false;
    if (search == null || search.isEmpty) {
      // search = await getRecentSearch();
    }
    Address _address = deliveryAddress.value;
    final Stream<Market> stream = await searchMarkets(search, _address);
    stream.listen((Market _market) {
      setState(() => markets.add(_market));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      setState((){
        doneSearchingMarkets = true;
      });
    });
  }

  void listenForProducts({String search}) async {
    doneSearchingProducts = false;
    if (search == null || search.isEmpty) {
      // search = await getRecentSearch();
    }
    Address _address = deliveryAddress.value;
    final Stream<Product> stream = await searchProducts(search, _address);
    stream.listen((Product _product) {
      setState(() => products.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      setState((){
        doneSearchingProducts = true;
      });
    });
  }

  Future<void> refreshSearch(search) async {
    print("refreshing search");
    setState(() {
      doneSearchingMarkets = false;
      doneSearchingProducts = false;
      markets = <Market>[];
      products = <Product>[];
      print("done set state");
    });
    listenForMarkets(search: search);
    listenForProducts(search: search);
  }

  void saveSearch(String search) {
    setRecentSearch(search);
  }
}
