import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

import 'dart:async';
// import 'package:connectivity/connectivity.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  bool isLoading = false;
  bool continueLoading = false;
  int skip = 0;
  int take = 10;

  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  String _message = "";

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future _loadData() async {
    continueLoading = true;
    // perform fetching data delay
    await new Future.delayed(new Duration(seconds: 1));

    print("load more markets!");

    if (skip + take > HomeController.totalMarkets) {
      print('disable the loader!');
      setState(() {
        continueLoading = false;
      });
    }
    // update data and loading status
    skip += take;
    _con.listenForTopMarkets(skip, take);
    setState(() {
      continueLoading = false;
      isLoading = false;
    });

    // setState(() {
    //   items
    //       .addAll(['skipping' + skip.toString() + ' taking' + take.toString()]);
    //   print('items: ' + items.toString());
    //   isLoading = false;
    //   skip += take;
    // });
  }

  Future<void> _sendAnalyticsEvent() async {
    print("Analytics: inside func");

    if (currentUser.value.apiToken == null) {
      print("showing user null");
      await analytics.logEvent(
        name: 'location_analysis',
        parameters: <String, dynamic>{
          'userLocation': "Unknown",
          'userEmail': "Guest Email",
        },
      );
      setMessage('logEvent succeeded');
    } else {
      if (settingsRepo.deliveryAddress.value.address == null) {
        print("showing address null");
        await analytics.logEvent(
          name: 'location_analysis',
          parameters: <String, dynamic>{
            'userLocation': "Unknown",
            'userEmail': currentUser.value.email,
          },
        );
        setMessage('logEvent succeeded');
      } else {
        print("everything okay");
        await analytics.logEvent(
          name: 'location_analysis',
          parameters: <String, dynamic>{
            'userLocation':
                settingsRepo.deliveryAddress.value.address.toString(),
            'userEmail': currentUser.value.email,
          },
        );
        setMessage('logEvent succeeded');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _sendAnalyticsEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.menu, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              value.appName ?? S.of(context).home,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
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
          onRefresh: _con.refreshHome,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchBarWidget(),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    trailing: Icon(
                      Icons.category,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).product_categories,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                CategoriesCarouselWidget(
                  categories: _con.categories,
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    trailing: IconButton(
                      onPressed: () {
                        if (currentUser.value.apiToken == null) {
                          _con.requestForCurrentLocation(context);
                        } else {
                          var bottomSheetController = widget
                              .parentScaffoldKey.currentState
                              .showBottomSheet(
                            (context) => DeliveryAddressBottomSheetWidget(
                                scaffoldKey: widget.parentScaffoldKey),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                          );
                          bottomSheetController.closed.then((value) {
                            _con.refreshHome();
                          });
                        }
                      },
                      icon: Icon(
                        Icons.my_location,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    title: Text(
                      'Trending Markets',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context).near_to +
                          " " +
                          (settingsRepo.deliveryAddress.value?.address ??
                              S.of(context).unknown),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                CardsCarouselWidget(
                    marketsList: _con.topMarkets,
                    heroTag: 'home_top_markets'),
                _con.topMarkets.isNotEmpty
                    ? Container(
                        height: continueLoading && _con.topMarkets.length > 1
                            ? 50.0
                            : 0,
                        color: Colors.transparent,
                        child: Center(
                          child: new CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(height: 0)

                //TESTT HIDING TRENDING PRODUCTS OF THIS WEEK
                // ListTile(
                //   dense: true,
                //   contentPadding: EdgeInsets.symmetric(horizontal: 20),
                //   leading: Icon(
                //     Icons.trending_up,
                //     color: Theme.of(context).hintColor,
                //   ),
                //   title: Text(
                //     S.of(context).trending_this_week,
                //     style: Theme.of(context).textTheme.headline4,
                //   ),
                //   subtitle: Text(
                //     S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                //     maxLines: 2,
                //     style: Theme.of(context).textTheme.caption,
                //   ),
                // ),
                // ProductsCarouselWidget(
                //     productsList: _con.trendingProducts,
                //     heroTag: 'home_product_carousel'),

                // Padding(
                //   padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                //   child: ListTile(
                //     dense: true,
                //     contentPadding: EdgeInsets.symmetric(vertical: 0),
                //     // leading: Icon(
                //     //   Icons.trending_up,
                //     //   color: Theme.of(context).hintColor,
                //     // ),
                //     title: Text(
                //       'Most Popular Markets',
                //       // S.of(context).most_popular,
                //       style: Theme.of(context).textTheme.headline4,
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: GridWidget(
                //     marketsList: _con.popularMarkets,
                //     heroTag: ' ',
                //   ),
                // ),

                //TESTT HIDING RECENT REVIEWS
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: ListTile(
                //     dense: true,
                //     contentPadding: EdgeInsets.symmetric(vertical: 20),
                //     leading: Icon(
                //       Icons.recent_actors,
                //       color: Theme.of(context).hintColor,
                //     ),
                //     title: Text(
                //       S.of(context).recent_reviews,
                //       style: Theme.of(context).textTheme.headline4,
                //     ),
                //   ),
                // ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: ReviewsListWidget(reviewsList: _con.recentReviews),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
