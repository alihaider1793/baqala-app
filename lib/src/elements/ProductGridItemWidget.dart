import 'package:flutter/material.dart';
import 'package:markets/src/repository/settings_repository.dart';

import '../models/product.dart';
import '../models/route_argument.dart';

class ProductGridItemWidget extends StatefulWidget {
  final String heroTag;
  final Product product;
  final VoidCallback onPressed;

  ProductGridItemWidget({Key key, this.heroTag, this.product, this.onPressed})
      : super(key: key);

  @override
  _ProductGridItemWidgetState createState() => _ProductGridItemWidgetState();
}

class _ProductGridItemWidgetState extends State<ProductGridItemWidget> {
  bool _isDiscounted = false;

  void _checkDiscountedPrice() {
    if (widget.product.discountPriceForGLView > 0.0 &&
        widget.product.discountPriceForGLView != null) {
      setState(() {
        _isDiscounted = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkDiscountedPrice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () {
        print(widget.product);
        Navigator.of(context).pushNamed('/Product',
            arguments: new RouteArgument(
                heroTag: this.widget.heroTag,
                id: this.widget.product.id,
                product: widget.product));
      },
      child: Container(
        // color: Colors.red,
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Hero(
                    tag: widget.heroTag + widget.product.id,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                NetworkImage(this.widget.product.image.thumb),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.bodyText1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1),
                      Text(
                        widget.product.market.name,
                        style: Theme.of(context).textTheme.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Text(
                                "${widget.product.capacity}-${widget.product.unit}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ),
                          // Spacer(),
                          Expanded(
                            flex: 2,
                            child: Container(
                              // alignment: Alignment.centerRight,
                              child: !_isDiscounted
                                  ? Text(
                                      setting.value?.defaultCurrency +
                                          "${widget.product.price.toStringAsFixed(2)}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                setting.value?.defaultCurrency +
                                                    "${widget.product.discountPriceForGLView.toStringAsFixed(2)}",
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  // fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2.0),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            setting.value?.defaultCurrency +
                                                "${widget.product.priceForGLView.toStringAsFixed(2)}",
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              // fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: 40,
              height: 40,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  widget.onPressed();
                },
                child: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                color: Theme.of(context).accentColor.withOpacity(0.9),
                shape: StadiumBorder(),
              ),
            ),

            // Positioned(
            //   top: 10,
            //   left: 10,
            //   child: Container(
            //       // margin: EdgeInsets.only(top: 10, right: 10),
            //       width: 40,
            //       height: 40,
            //       child: Column(
            //         children: [
            //           Text(
            //             "${widget.product.price}",
            //             style: TextStyle(
            //               color: Colors.red,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           )
            //         ],
            //       )),
            // ),
          ],
        ),
      ),
    );
  }
}
