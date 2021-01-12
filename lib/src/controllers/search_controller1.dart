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

class SearchController1 extends ControllerMVC {
  List<Market> markets1 = <Market>[];
  List<Product> products1 = <Product>[];

  List<Cart> carts = [];
  bool loadCart = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  bool doneSearchingProducts = false;

  SearchController1() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // listenForProducts1();
  }

  Future<void> listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameMarkets(Product product) {
    if (carts.isNotEmpty) {
      print('inside search controller1 isSame: ' +
          (carts[0].product?.market?.id == product.market?.id).toString());
      print('inside search controller1 isSame: ' +
          carts[0].product?.market?.id.toString());
      print(
          'inside search controller1 isSame: ' + product.market?.id.toString());
      return carts[0].product?.market?.id == MenuWidget.openedMarket;
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

  void listenForProducts1({String search}) async {
    doneSearchingProducts = false;
    if (search == null || search.isEmpty) {
      // search = await getRecentSearch();
    }
    Address _address = deliveryAddress.value;
    final Stream<Product> stream = await searchProducts1(search, _address);
    stream.listen((Product _product) {
      setState(() => products1.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      print('product searched: ' + products1.toString());
      setState((){
        doneSearchingProducts = true;
      });
    });
  }

  Future<void> refreshSearch1(search) async {
    setState(() {
      doneSearchingProducts = false;
      markets1 = <Market>[];
      products1 = <Product>[];
    });
    listenForProducts1(search: search);
  }

  void saveSearch(String search) {
    setRecentSearch(search);
  }
}
