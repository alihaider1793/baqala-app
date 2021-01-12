import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:markets/src/repository/settings_repository.dart';

import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class ProductListItemWidget extends StatefulWidget {
  String heroTag;
  Product product;

  ProductListItemWidget({Key key, this.heroTag, this.product})
      : super(key: key);

  @override
  _ProductListItemWidgetState createState() => _ProductListItemWidgetState();
}

class _ProductListItemWidgetState extends State<ProductListItemWidget> {
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
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        print(widget.product);
        Navigator.of(context).pushNamed('/Product',
            arguments: new RouteArgument(
                heroTag: this.widget.heroTag,
                id: this.widget.product.id,
                product: this.widget.product));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: widget.heroTag + widget.product.id,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                      image: NetworkImage(widget.product.image.thumb),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.product.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          widget.product.market.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          "${widget.product.capacity}-${widget.product.unit}",
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  !_isDiscounted
                      ? Helper.getPrice(widget.product.price, context,
                          style: Theme.of(context).textTheme.headline4)
                      : Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  setting.value?.defaultCurrency +
                                      "${widget.product.discountPriceForGLView}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              setting.value?.defaultCurrency +
                                  "${widget.product.priceForGLView}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
