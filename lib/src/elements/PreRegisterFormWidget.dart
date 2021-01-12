import 'package:flutter/material.dart';
import 'package:markets/generated/l10n.dart';
import 'package:markets/src/controllers/user_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RegisterShopWidget extends StatefulWidget {
  @override
  _RegisterShopWidgetState createState() => _RegisterShopWidgetState();
}

class _RegisterShopWidgetState extends StateMVC<RegisterShopWidget> {
  UserController _con;

  _RegisterShopWidgetState() : super(UserController()) {
    _con = controller;
  }

  GlobalKey<FormState> _preRegisterShopKey;
  String _name = '';
  String _email = '';
  String _shopName = '';
  String _shopAddress = '';
  String _phone = '';

  Future<void> validate() async {
    await _con.preRegisterShop(
        name: _name,
        email: _email,
        shopAddress: _shopAddress,
        shopName: _shopName,
        phone: _phone);
  }

  @override
  void initState() {
    // TODO: implement initState
    _preRegisterShopKey = new GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${S.of(context).pre_register_shop}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 50,
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                )
              ]),
          // width: config.App(context).appWidth(88),
          child: Form(
            key: _preRegisterShopKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => _name = input,
                    validator: (input) => input.length < 3
                        ? S.of(context).should_be_more_than_3_letters
                        : null,
                    decoration: InputDecoration(
                      labelText: S.of(context).full_name,
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintText: S.of(context).john_doe,
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.person_outline,
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (input) => _email = input,
                    validator: (input) => !input.contains('@')
                        ? S.of(context).should_be_a_valid_email
                        : null,
                    decoration: InputDecoration(
                      labelText: S.of(context).email,
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'johndoe@gmail.com',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.alternate_email,
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => _shopName = input,
                    validator: (input) => input.length < 3
                        ? S.of(context).should_be_more_than_3_characters
                        : null,
                    decoration: InputDecoration(
                      labelText: S.of(context).shop_name,
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Grocery Shop',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.shop,
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.streetAddress,
                    onSaved: (input) => _shopAddress = input,
                    validator: (input) => input.length < 6
                        ? S.of(context).should_be_more_than_6_letters
                        : null,
                    decoration: InputDecoration(
                      labelText: S.of(context).shop_address,
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Shop Address',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.location_city,
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    onSaved: (input) => _phone = input,
                    validator: (input) =>
                        input.contains('+') && input.length >= 7
                            ? null
                            : S.of(context).should_be_a_valid_phone,
                    decoration: InputDecoration(
                      labelText: S.of(context).phone,
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '+############',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.phone,
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () async {
                      if (!_preRegisterShopKey.currentState.validate()) {
                        return;
                      } else if (_preRegisterShopKey.currentState.validate()) {
                        _preRegisterShopKey.currentState.save();
                        await validate();
                      }
                    },
                    child: Text(
                      "${S.of(context).submit}",
                      style: TextStyle(
                        letterSpacing: 2.0,
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green)),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
