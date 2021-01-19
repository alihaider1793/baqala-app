import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markets/src/helpers/helper.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../repository/user_repository.dart';
import '../controllers/category_controller.dart';
import '../elements/ProductGridItemWidget.dart';
import '../elements/ProductListItemWidget.dart';
import '../elements/SearchBarWidget1.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/market_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ProductsCarouselWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument routeArgument;
  static String openedMarket = '';

  MenuWidget({Key key, this.routeArgument}) : super(key: key);
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  MarketController _con;
  List<String> selectedCategories;
  String layout = 'grid';
  double productGridViewWidgetCardHeight;
  bool _hasSpecialOffer;
  bool _isSaleTagSelected = false;

  _MenuWidgetState() : super(MarketController()) {
    _con = controller;
  }

  bool isLoading = false;
  bool continueLoading = false;
  int skip = 0;
  int take = 10;

  Future _loadData() async {
    continueLoading = true;
    // perform fetching data delay
    await new Future.delayed(new Duration(seconds: 1));

    print("load more market products :" +
        CategoryController.totalMarketProducts.toString() +
        ' skip : ' +
        (skip + take).toString());

    if (skip + take > CategoryController.totalMarketProducts) {
      print('disable the loader!');
      setState(() {
        isLoading = false;
        continueLoading = false;
      });
    }

    // update data and loading status
    skip += take;
    _con.listenForProducts(skip, 10, widget.routeArgument.id,
        categoriesId: this.selectedCategories);
    setState(() {
      isLoading = false;
      continueLoading = false;
    });
  }

  @override
  void initState() {
    _hasSpecialOffer = widget.routeArgument.marketData.specialOffer;
    print(widget.routeArgument.marketData.id);

    _con.listenForCart().then((value) {
      _con.market = (new Market())..id = widget.routeArgument.id;
      MenuWidget.openedMarket = widget.routeArgument.id;
      _con.listenForTrendingProducts(widget.routeArgument.id);
      // _con.listenForCategories();
      _con.listenForMarketCategories(widget.routeArgument.marketData.id);
      selectedCategories = ['0'];
      _con.listenForProducts(0, 10, widget.routeArgument.id);
      productGridViewWidgetCardHeight =
          MediaQuery.of(context).size.height * 0.30;
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _con.market?.name ?? '',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 0)),
        ),
        actions: <Widget>[
          _con.loadCart
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22.5, vertical: 15),
                  child: SizedBox(
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : new ShoppingCartButtonWidget(
                  iconColor: Theme.of(context).hintColor,
                  labelColor: Theme.of(context).accentColor),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          print(scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent);
          if (!isLoading &&
              scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
            print("calling func");
            _loadData();
            // start loading data
            setState(() {
              isLoading = true;
            });
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget1(),
              ),
              _con.featuredProducts.isEmpty
                  ? SizedBox(height: 0)
                  : ListTile(
                      dense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      trailing: Icon(
                        Icons.bookmark,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        // S.of(context).featured_products,
                        'Top Featured Products: ',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
              _con.featuredProducts.isEmpty
                  ? SizedBox(height: 0)
                  : ProductsCarouselWidget(
                      heroTag: 'menu_trending_product',
                      productsList: _con.trendingProducts),
              ListTile(
                dense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  S.of(context).products,
                  style: Theme.of(context).textTheme.headline4,
                ),
                subtitle: Text(
                  S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              Row(
                children: [
                  !_hasSpecialOffer
                      ? SizedBox(width: 0.0)
                      : Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: RawChip(
                              isEnabled: _con.doneFetchingProducts,
                              elevation: 0,
                              label: Text(
                                "Offers",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              labelStyle: _isSaleTagSelected
                                  ? Theme.of(context).textTheme.bodyText2.merge(
                                      TextStyle(
                                          color:
                                              Theme.of(context).primaryColor))
                                  : Theme.of(context).textTheme.bodyText2,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 15),
                              backgroundColor:
                                  Theme.of(context).focusColor.withOpacity(0.1),
                              selectedColor: Colors.red,
                              selected: _isSaleTagSelected,
                              //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                              showCheckmark: false,
                              onSelected: (bool value) {
                                print("offer tapped");
                                setState(() {
                                  _isSaleTagSelected = !_isSaleTagSelected;
                                  if (_isSaleTagSelected) {
                                    this.selectedCategories.clear();
                                    _con.listenForDiscountedProducts(
                                        0, 10, widget.routeArgument.id);
                                  } else {
                                    this.selectedCategories = ['0'];
                                    _con.selectCategory(
                                        this.selectedCategories);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                  Expanded(
                    flex: 4,
                    child: _con.categories.isEmpty
                        ? SizedBox(height: 90)
                        : Container(
                            height: 90,
                            child: ListView(
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(_con.categories.length,
                                  (index) {
                                var _category =
                                    _con.categories.elementAt(index);
                                var _selected = this
                                    .selectedCategories
                                    .contains(_category.id);
                                return Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 20),
                                  child: RawChip(
                                    isEnabled: _con.doneFetchingProducts,
                                    elevation: 0,
                                    label: Text(_category.name),
                                    labelStyle: _selected
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .merge(TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor))
                                        : Theme.of(context).textTheme.bodyText2,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 15),
                                    backgroundColor: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.1),
                                    selectedColor:
                                        Theme.of(context).accentColor,
                                    selected: _selected,
                                    //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                                    showCheckmark: false,
                                    avatar: (_category.id == '0')
                                        ? null
                                        : (_category.image.url
                                                .toLowerCase()
                                                .endsWith('.svg')
                                            ? SvgPicture.network(
                                                _category.image.url,
                                                color: _selected
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .accentColor,
                                              )
                                            : CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: _category.image.icon,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                  'assets/img/loading.gif',
                                                  fit: BoxFit.cover,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              )),
                                    onSelected: (bool value) {
                                      setState(() {
                                        _isSaleTagSelected = false;
                                        if (_category.id == '0') {
                                          this.selectedCategories = ['0'];
                                        } else {
                                          this.selectedCategories.removeWhere(
                                              (element) => element == '0');
                                        }

                                        if (value) {
                                          this
                                              .selectedCategories
                                              .add(_category.id);
                                        } else {
                                          this.selectedCategories.removeWhere(
                                              (element) =>
                                                  element == _category.id);
                                        }
                                        _con.selectCategory(
                                            this.selectedCategories);
                                      });
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                  ),
                ],
              ),
              _con.products.isEmpty
                  ? SizedBox(height: 0)
                  : Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      child: _con.products.isEmpty
                          ? CircularLoadingWidget(height: 250)
                          : Offstage(
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
                    ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: _con.products.isEmpty && !_con.doneFetchingProducts
                    ? Column(
                        children: [
                          CircularLoadingWidget(height: 50),
                          SizedBox(height: 15.0),
                          Text("Fetching products...")
                        ],
                      )
                    : _con.products.isEmpty && _con.doneFetchingProducts
                        ? Center(
                            child: Text("${S.of(context).noProductFound}"),
                          )
                        : Offstage(
                            offstage: this.layout != 'grid',
                            child: GridView.count(
                              // to adjust height of grid widgets
                              childAspectRatio:
                                  ((MediaQuery.of(context).size.width / 2) /
                                      (Helper.getScreenHeight(context) * 0.30)),
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
                                return ProductGridItemWidget(
                                    heroTag: 'category_grid',
                                    product: _con.products.elementAt(index),
                                    onPressed: () {
                                      if (currentUser.value.apiToken == null) {
                                        Navigator.of(context)
                                            .pushNamed('/Login');
                                      } else {
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
              ),
              continueLoading
                  ? Container(
                      height: continueLoading ? 50.0 : 0,
                      color: Colors.transparent,
                      child: Center(
                        child: new CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(height: 0)
            ],
          ),
        ),
      ),
    );
    // body: Column(
    //   children: <Widget>[
    //     Expanded(
    //       child: NotificationListener<ScrollNotification>(
    //         onNotification: (ScrollNotification scrollInfo) {
    //           if (!isLoading &&
    //               scrollInfo.metrics.pixels ==
    //                   scrollInfo.metrics.maxScrollExtent) {
    //             _loadData();
    //             // start loading data
    //             setState(() {
    //               isLoading = true;
    //             });
    //           }
    //         },
    //         child: ListView.builder(
    //           itemCount: items.length,
    //           itemBuilder: (context, index) {
    //             return ListTile(
    //               title: Text('${items[index]}'),
    //             );
    //           },
    //         ),
    //       ),
    //     ),
    //     Container(
    //       height: isLoading ? 50.0 : 0,
    //       color: Colors.transparent,
    //       child: Center(
    //         child: new CircularProgressIndicator(),
    //       ),
    //     ),
    //   ],
    // ),
    // );
  }
}
