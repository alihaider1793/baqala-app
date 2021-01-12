import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/market.dart';

// ignore: must_be_immutable
class CardWidget extends StatelessWidget {
  Market market;
  String heroTag;

  CardWidget({Key key, this.market, this.heroTag}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Image of the card
          Stack(
            fit: StackFit.loose,
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              Hero(
                tag: this.heroTag + market.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: CachedNetworkImage(
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: market.image.url,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  market.specialOffer
                      ? Container(
                          // child: Text("hello"),
                          // margin: EdgeInsets.only(top: 10, right: 10),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/img/special_offers_tag.png"),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          // child: Text(
                          //   "hello",
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // )
                        )
                      : SizedBox(height: 0.0, width: 0.0),
                  // Spacer(),
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                        color: market.closed ? Colors.redAccent : Colors.green,
                        borderRadius: BorderRadius.circular(5)),
                    child: market.closed
                        ? Text(
                            S.of(context).closed,
                            style: Theme.of(context).textTheme.caption.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold)),
                          )
                        : Text(
                            S.of(context).open,
                            style: Theme.of(context).textTheme.caption.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                  ),

                  // TESTT HIDE PICKUP/DELIVERY OPTION
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  //   decoration: BoxDecoration(
                  //       color: Helper.canDelivery(market)
                  //           ? Colors.green
                  //           : Colors.orange,
                  //       borderRadius: BorderRadius.circular(24)),
                  //   child: Helper.canDelivery(market)
                  //       ? Text(
                  //           S.of(context).delivery,
                  //           style: Theme.of(context).textTheme.caption.merge(
                  //               TextStyle(
                  //                   color: Theme.of(context).primaryColor,
                  //                   fontWeight: FontWeight.bold)),
                  //         )
                  //       : Text(
                  //           S.of(context).pickup,
                  //           style: Theme.of(context).textTheme.caption.merge(
                  //               TextStyle(
                  //                   color: Theme.of(context).primaryColor,
                  //                   fontWeight: FontWeight.bold)),
                  //         ),
                  // ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        market.name,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        Helper.skipHtml(market.description),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      SizedBox(height: 5),
                      Row(
                        children:
                            Helper.getStarsList(double.parse(market.rate)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          // TESTT HIDE/DISABLE FUNCTIONALITY TO OPEN MAP FROM HOME SCREEN
                          // Navigator.of(context).pushNamed('/Pages',
                          //     arguments:
                          //         new RouteArgument(id: '1', param: market));
                        },
                        child: Icon(Icons.motorcycle,
                            color: Theme.of(context).primaryColor),
                        color: Colors.yellow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      market.deliveryTime > 0
                          ? Text(
                              market.deliveryTime.toString() + ' min',
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            )
                          : SizedBox(height: 0)
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
