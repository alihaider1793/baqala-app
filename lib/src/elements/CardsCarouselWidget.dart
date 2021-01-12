import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';

// ignore: must_be_immutable
class CardsCarouselWidget extends StatefulWidget {
  List<Market> marketsList;
  String heroTag;

  CardsCarouselWidget({Key key, this.marketsList, this.heroTag})
      : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("rendering markets");
    return widget.marketsList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
            height: 275 * widget.marketsList.length.toDouble(),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.marketsList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {

                    if(widget.marketsList.elementAt(index).closed)
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
                              id: widget.marketsList.elementAt(index).id,
                              heroTag: widget.heroTag,
                              marketData: widget.marketsList.elementAt(index),
                            ));
                      }
                  },
                  child: CardWidget(
                      market: widget.marketsList.elementAt(index),
                      heroTag: widget.heroTag),
                );
              },
            ),
          );
  }
}
