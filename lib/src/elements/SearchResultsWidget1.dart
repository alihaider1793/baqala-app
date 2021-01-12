import 'package:flutter/material.dart';
import 'package:markets/src/helpers/helper.dart';
import '../pages/menu_list.dart';
import '../repository/user_repository.dart';
import '../controllers/search_controller1.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import 'AddToCartAlertDialog.dart';
import 'CircularLoadingWidget.dart';
import 'ProductGridItemWidget.dart';
import 'ProductListItemWidget.dart';

import 'package:loading_overlay/loading_overlay.dart';

class SearchResultWidget1 extends StatefulWidget {
  final String heroTag;

  SearchResultWidget1({Key key, this.heroTag}) : super(key: key);

  @override
  _SearchResultWidgetState1 createState() => _SearchResultWidgetState1();
}

class _SearchResultWidgetState1 extends StateMVC<SearchResultWidget1> {
  SearchController1 _con;
  String layout = 'grid';
  double productGridViewWidgetCardHeight;
  TextEditingController _textEditingController;

  _SearchResultWidgetState1() : super(SearchController1()) {
    _con = controller;
  }

  @override
  void initState() {
    _textEditingController = new TextEditingController();
    _con.listenForCart().then((value) {
      productGridViewWidgetCardHeight =
          MediaQuery.of(context).size.height * 0.30;
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  color: Theme.of(context).hintColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  S.of(context).search,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (text) async {
                  await _con.refreshSearch1(text);
                  _con.saveSearch(text);
                },
                autofocus: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  hintText: S.of(context).search_for_markets_or_products,
                  hintStyle: Theme.of(context)
                      .textTheme
                      .caption
                      .merge(TextStyle(fontSize: 14)),
                  prefixIcon:
                      Icon(Icons.search, color: Theme.of(context).accentColor),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.1))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.1))),
                ),
              ),
            ),
            _con.products1.isEmpty && !_con.doneSearchingProducts && _textEditingController.value.text.isNotEmpty
                ? CircularLoadingWidget(height: 288)
                : _con.products1.isEmpty && _con.doneSearchingProducts
                ? Text("No results found!")
                : Expanded(
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      this.layout = 'list';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.format_list_bulleted,
                                    color: this.layout == 'list'
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).focusColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      this.layout = 'grid';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.apps,
                                    color: this.layout == 'grid'
                                        ? Theme.of(context).accentColor
                                        : Theme.of(context).focusColor,
                                  ),
                                )
                              ],
                            ),
                            title: Text(
                              S.of(context).products_results,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        ),
                        // ListView.separated(
                        //   scrollDirection: Axis.vertical,
                        //   shrinkWrap: true,
                        //   primary: false,
                        //   itemCount: _con.products1.length,
                        //   separatorBuilder: (context, index) {
                        //     return SizedBox(height: 10);
                        //   },
                        //   itemBuilder: (context, index) {
                        //     return ProductItemWidget(
                        //       heroTag: 'search_list',
                        //       product: _con.products1.elementAt(index),
                        //     );
                        //   },
                        // ),
                        Offstage(
                          offstage: this.layout != 'list',
                          child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: _con.products1.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              return ProductListItemWidget(
                                heroTag: 'favorites_list',
                                product: _con.products1.elementAt(index),
                              );
                            },
                          ),
                        ),
                        Offstage(
                          offstage: this.layout != 'grid',
                          child: GridView.count(
                            // to adjust height of grid widgets
                            childAspectRatio:
                                ((MediaQuery.of(context).size.width / 2) /
                                    (Helper.getScreenHeight(context)*0.30)),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 20,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            // Create a grid with 2 columns. If you change the scrollDirection to
                            // horizontal, this produces 2 rows.
                            crossAxisCount:
                                MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? 2
                                    : 4,
                            // Generate 100 widgets that display their index in the List.
                            children:
                                List.generate(_con.products1.length, (index) {
                                  print(_con.products1[index].market.name);
                              return ProductGridItemWidget(
                                  heroTag: 'category_grid',
                                  product: _con.products1.elementAt(index),
                                  onPressed: () {
                                    if (currentUser.value.apiToken == null) {
                                      Navigator.of(context).pushNamed('/Login');
                                    } else {
                                      print(
                                          'id of selected product in search: ' +
                                              MenuWidget.openedMarket);
                                      if (_con.isSameMarkets(
                                          _con.products1.elementAt(index))) {
                                        _con.addToCart(
                                            _con.products1.elementAt(index));
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            // return object of type Dialog
                                            return AddToCartAlertDialogWidget(
                                                oldProduct: _con.carts
                                                    .elementAt(0)
                                                    ?.product,
                                                newProduct: _con.products1
                                                    .elementAt(index),
                                                onPressed: (product,
                                                    {reset: true}) {
                                                  return _con.addToCart(
                                                      _con.products1
                                                          .elementAt(index),
                                                      reset: true);
                                                });
                                          },
                                        );
                                      }
                                    }
                                  });
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
      isLoading: _con.loadCart,
      // demo of some additional parameters
      opacity: 0.1,
      progressIndicator: CircularProgressIndicator(),
    );
  }
}
