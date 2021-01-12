import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:markets/src/helpers/helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../pages/menu_list.dart';
import '../repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/search_controller.dart';
import '../elements/CardWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/route_argument.dart';
import 'AddToCartAlertDialog.dart';
import 'ProductGridItemWidget.dart';
import 'ProductListItemWidget.dart';

class SearchResultWidget extends StatefulWidget {
  final String heroTag;

  SearchResultWidget({Key key, this.heroTag}) : super(key: key);

  @override
  _SearchResultWidgetState createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends StateMVC<SearchResultWidget> {
  SearchController _con;
  String layout = 'grid';
  double productGridViewWidgetCardHeight;
  TextEditingController _textEditingController;

  _SearchResultWidgetState() : super(SearchController()) {
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
                subtitle: Text(
                  S.of(context).ordered_by_nearby_first,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (text) async {
                  print("on submitted");
                  await _con.refreshSearch(text);
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
            _con.markets.isEmpty && _con.products.isEmpty && !_con.doneSearchingProducts && !_con.doneSearchingMarkets && _textEditingController.value.text.isNotEmpty
                ? CircularLoadingWidget(height: 288)
                : _con.markets.isEmpty && _con.products.isEmpty && _con.doneSearchingProducts && _con.doneSearchingMarkets
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
                        Offstage(
                          offstage: this.layout != 'list',
                          child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: _con.products.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              return ProductListItemWidget(
                                heroTag: 'favorites_list',
                                product: _con.products.elementAt(index),
                              );
                            },
                          ),
                        ),
                        Offstage(
                          offstage: this.layout != 'grid',
                          child: GridView.count(
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
                                List.generate(_con.products.length, (index) {
                                  // print("screen height");
                                  // print(Helper.getScreenHeight(context));
                              return ProductGridItemWidget(
                                  heroTag: 'category_grid',
                                  product: _con.products.elementAt(index),
                                  onPressed: () {
                                    if (currentUser.value.apiToken == null) {
                                      Navigator.of(context).pushNamed('/Login');
                                    } else {
                                      print(
                                          'id of selected product in search: ' +
                                              MenuWidget.openedMarket);
                                      if (_con.isSameMarkets(
                                          _con.products.elementAt(index))) {
                                        _con.addToCart(
                                            _con.products.elementAt(index));
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            // return object of type Dialog
                                            return AddToCartAlertDialogWidget(
                                                oldProduct: _con.carts
                                                    .elementAt(0)
                                                    ?.product,
                                                newProduct: _con.products
                                                    .elementAt(index),
                                                onPressed: (product,
                                                    {reset: true}) {
                                                  return _con.addToCart(
                                                      _con.products
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
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 20, right: 20),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            title: Text(
                              S.of(context).markets_results,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: _con.markets.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {

                                if(_con.markets.elementAt(index).closed)
                                {
                                  Alert(
                                    context: context,
                                    type: AlertType.error,
                                    title: "Closed",
                                    desc:
                                    "This market will be back soon!",
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Ok",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        width: 120,
                                      )
                                    ],
                                  ).show();
                                }
                                else
                                  {
                                    Navigator.of(context).pushNamed('/Details',
                                        arguments: RouteArgument(
                                            id: _con.markets.elementAt(index).id,
                                            heroTag: widget.heroTag,
                                            marketData: _con.markets.elementAt(index)
                                        ));
                                  }

                              },
                              child: CardWidget(
                                  market: _con.markets.elementAt(index),
                                  heroTag: widget.heroTag),
                            );
                          },
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
