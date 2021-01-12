import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markets/src/controllers/category_controller.dart';
import 'package:markets/src/elements/ProductGridItemWidget.dart';
import 'package:markets/src/elements/ProductListItemWidget.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/market_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/GalleryCarouselWidget.dart';
import '../elements/ProductItemWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class DetailsWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  DetailsWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends StateMVC<DetailsWidget> {
  MarketController _con;
  String layout = 'list';
  double productGridViewWidgetCardHeight;

  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  String _message = "";
//  String analyUserEmail = _con.market?.name;

  _DetailsWidgetState() : super(MarketController()) {
    _con = controller;
  }

  bool isLoading = false;
  bool continueLoading = true;
  int skip = 0;
  int take = 10;

  Future _loadData() async {
    // perform fetching data delay
    await new Future.delayed(new Duration(seconds: 1));

    print("load more featured products! " +
        CategoryController.totalCategoryProducts.toString() +
        ' skip: ' +
        (skip + take).toString());
    // update data and loading status

    if (skip + take > CategoryController.totalCategoryProducts) {
      print('disable the loader!');
      setState(() {
        isLoading = false;
        continueLoading = false;
      });
    }

    // update data and loading status
    skip += take;
    // _con.listenForProducts(skip, 10, widget.routeArgument.id);
    _con.listenForFeaturedProducts(skip, 10, widget.routeArgument.id);
    isLoading = false;
    // setState(() {
    //   items
    //       .addAll(['skipping' + skip.toString() + ' taking' + take.toString()]);
    //   print('items: ' + items.toString());
    //   isLoading = false;
    //   skip += take;
    // });
  }

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _sendAnalyticsEvent() async {
    print("Analytics: inside func");
    await analytics.logEvent(
      name: 'shop_analysis',
      parameters: <String, dynamic>{
        'shopName': widget.routeArgument.marketData.name,
        'userName': currentUser.value.apiToken != null
            ? currentUser.value.name
            : "Guest User",
        'userEmail': currentUser.value.apiToken != null
            ? currentUser.value.email
            : "Guest Email",
      },
    );
    setMessage('logEvent succeeded');
    print("Analytics: market name is ${widget.routeArgument.marketData.name}");
    print("Analytics: func executed");
    print("Current user data: ${currentUser.value.name}");
  }

  @override
  void initState() {
    _con.listenForMarket(id: widget.routeArgument.id);
    _con.listenForGalleries(widget.routeArgument.id);
    _con.listenForFeaturedProducts(0, 10, widget.routeArgument.id);
    _con.listenForMarketReviews(id: widget.routeArgument.id);
    _sendAnalyticsEvent();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            print(widget.routeArgument.marketData);
            Navigator.of(context).pushNamed('/Menu',
                arguments: new RouteArgument(id: widget.routeArgument.id,
                    marketData: widget.routeArgument.marketData));
          },
          isExtended: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: Icon(
            Icons.shopping_basket,
            color: Theme.of(context).primaryColor,
          ),
          label: Text(
            S.of(context).shopping,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (!isLoading &&
                scrollNotification.metrics.pixels ==
                    scrollNotification.metrics.maxScrollExtent) {
              _loadData();
              // start loading data
              setState(() {
                isLoading = true;
              });
            }
          },
          child: RefreshIndicator(
            onRefresh: _con.refreshMarket,
            child: _con.market == null
                ? CircularLoadingWidget(height: 500)
                : Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CustomScrollView(
                        primary: true,
                        shrinkWrap: false,
                        slivers: <Widget>[
                          SliverAppBar(
                            backgroundColor:
                                Theme.of(context).accentColor.withOpacity(0.9),
                            expandedHeight: 300,
                            elevation: 0,
                            iconTheme: IconThemeData(
                                color: Theme.of(context).primaryColor),
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              background: Hero(
                                tag: (widget?.routeArgument?.heroTag ?? '') +
                                    _con.market.id,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: _con.market.image.url,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/img/loading.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Wrap(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20, left: 20, bottom: 10, top: 25),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          _con.market?.name ?? '',
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 32,
                                        child: Chip(
                                          padding: EdgeInsets.all(0),
                                          label: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(_con.market.rate,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .merge(TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor))),
                                              Icon(
                                                Icons.star_border,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .accentColor
                                              .withOpacity(0.9),
                                          shape: StadiumBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 20),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: _con.market.closed
                                              ? Colors.grey
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: _con.market.closed
                                          ? Text(
                                              S.of(context).closed,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .merge(TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                            )
                                          : Text(
                                              S.of(context).open,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .merge(TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                            ),
                                    ),
                                    SizedBox(width: 10),
                                    // Container(
                                    //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                    //   decoration: BoxDecoration(
                                    //       color: Helper.canDelivery(_con.market) ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(24)),
                                    //   child: Helper.canDelivery(_con.market)
                                    //       ? Text(
                                    //           S.of(context).delivery,
                                    //           style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                    //         )
                                    //       : Text(
                                    //           S.of(context).pickup,
                                    //           style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                    //         ),
                                    // ),
                                    Expanded(child: SizedBox(height: 0)),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: Helper.canDelivery(_con.market)
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Text(
                                        Helper.getDistance(
                                            _con.market.distance,
                                            Helper.of(context).trans(
                                                setting.value.distanceUnit)),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .merge(TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Helper.applyHtml(
                                      context, _con.market.description),
                                ),
                                ImageThumbCarouselWidget(
                                    galleriesList: _con.galleries),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 0),
                                    trailing: Icon(
                                      Icons.stars,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    title: Text(
                                      S.of(context).information,
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Helper.applyHtml(
                                      context, _con.market.information),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  color: Theme.of(context).primaryColor,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          _con.market.address ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: SizedBox(
                                          width: 42,
                                          height: 42,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  '/Pages',
                                                  arguments: new RouteArgument(
                                                      id: '1',
                                                      param: _con.market));
                                            },
                                            child: Icon(
                                              Icons.directions,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 24,
                                            ),
                                            color: Theme.of(context)
                                                .accentColor
                                                .withOpacity(0.9),
                                            shape: StadiumBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 20, vertical: 20),
                                //   margin: const EdgeInsets.symmetric(vertical: 5),
                                //   color: Theme.of(context).primaryColor,
                                //   child: Row(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: <Widget>[
                                //       Expanded(
                                //         child: Text(
                                //           '${_con.market.phone} \n${_con.market.mobile}',
                                //           overflow: TextOverflow.ellipsis,
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .bodyText1,
                                //         ),
                                //       ),
                                //       SizedBox(width: 10),
                                //       Container(
                                //         decoration: BoxDecoration(
                                //             color: Colors.green,
                                //             borderRadius:
                                //                 BorderRadius.circular(5)),
                                //         child: SizedBox(
                                //           width: 42,
                                //           height: 42,
                                //           child: FlatButton(
                                //             padding: EdgeInsets.all(0),
                                //             onPressed: () {
                                //               launch("tel:${_con.market.mobile}");
                                //             },
                                //             child: Icon(
                                //               Icons.call,
                                //               color:
                                //                   Theme.of(context).primaryColor,
                                //               size: 24,
                                //             ),
                                //             color: Theme.of(context)
                                //                 .accentColor
                                //                 .withOpacity(0.9),
                                //             shape: StadiumBorder(),
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                _con.featuredProducts.isEmpty
                                    ? SizedBox(height: 0)
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: ListTile(
                                          dense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
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
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Theme.of(context)
                                                          .focusColor,
                                                ),
                                              ),
                                              // IconButton(
                                              //   onPressed: () {
                                              //     setState(() {
                                              //       this.layout = 'grid';
                                              //     });
                                              //   },
                                              //   icon: Icon(
                                              //     Icons.apps,
                                              //     color: this.layout == 'grid'
                                              //         ? Theme.of(context)
                                              //             .accentColor
                                              //         : Theme.of(context)
                                              //             .focusColor,
                                              //   ),
                                              // )
                                            ],
                                          ),
                                          title: Text(
                                            S.of(context).featured_products,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                      ),
                                _con.featuredProducts.isEmpty
                                    ? SizedBox(height: 0)
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 0),
                                        child: _con.featuredProducts.isEmpty
                                            ? CircularLoadingWidget(height: 500)
                                            : Offstage(
                                                offstage: this.layout != 'list',
                                                child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  itemCount: _con
                                                      .featuredProducts.length,
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return SizedBox(height: 10);
                                                  },
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ProductListItemWidget(
                                                      heroTag:
                                                          'details_featured_product',
                                                      product: _con
                                                          .featuredProducts
                                                          .elementAt(index),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: _con.featuredProducts.isEmpty
                                      ? SizedBox(height: 0)
                                      : Offstage(
                                          offstage: this.layout != 'grid',
                                          child: GridView.count(
                                            // to adjust height of grid widgets
                                            // childAspectRatio: ((MediaQuery.of(
                                            //                 context)
                                            //             .size
                                            //             .width /
                                            //         2) /
                                            //     productGridViewWidgetCardHeight),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            primary: false,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 20,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            // Create a grid with 2 columns. If you change the scrollDirection to
                                            // horizontal, this produces 2 rows.
                                            crossAxisCount:
                                                MediaQuery.of(context)
                                                            .orientation ==
                                                        Orientation.portrait
                                                    ? 2
                                                    : 4,
                                            // Generate 100 widgets that display their index in the List.
                                            children: List.generate(
                                                _con.featuredProducts.length,
                                                (index) {
                                              return ProductGridItemWidget(
                                                  heroTag: 'category_grid',
                                                  product: _con.featuredProducts
                                                      .elementAt(index),
                                                  onPressed: () {});
                                            }),
                                          ),
                                        ),
                                ),
                                _con.featuredProducts.isEmpty
                                    ? SizedBox(height: 0)
                                    : Container(
                                        height: isLoading ? 50.0 : 0,
                                        color: Colors.transparent,
                                        child: Center(
                                          child:
                                              new CircularProgressIndicator(),
                                        ),
                                      ),
                                SizedBox(height: 100),
                                _con.reviews.isEmpty
                                    ? SizedBox(height: 5)
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        child: ListTile(
                                          dense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          leading: Icon(
                                            Icons.recent_actors,
                                            color: Theme.of(context).hintColor,
                                          ),
                                          title: Text(
                                            S.of(context).what_they_say,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ),
                                      ),
                                _con.reviews.isEmpty
                                    ? SizedBox(height: 5)
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: ReviewsListWidget(
                                            reviewsList: _con.reviews),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 32,
                        right: 20,
                        child: ShoppingCartFloatButtonWidget(
                          iconColor: Theme.of(context).primaryColor,
                          labelColor: Theme.of(context).hintColor,
                          routeArgument: RouteArgument(
                              param: '/Details', id: widget.routeArgument.id),
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
