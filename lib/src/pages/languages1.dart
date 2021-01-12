import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/language.dart';
import 'package:url_launcher/url_launcher.dart';

class LanguagesWidget1 extends StatefulWidget {
  @override
  _LanguagesWidgetState createState() => _LanguagesWidgetState();
}

class _LanguagesWidgetState extends State<LanguagesWidget1> {
  LanguagesList languagesList;

  @override
  void initState() {
    languagesList = new LanguagesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).help__support,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          )),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: ListTile(
            //     contentPadding: EdgeInsets.symmetric(vertical: 0),
            //     // trailing: Icon(
            //     //   Icons.phone,
            //     //   color: Theme.of(context).hintColor,
            //     // ),
            //     // title: Text(
            //     //   S.of(context).help__support,
            //     //   maxLines: 1,
            //     //   overflow: TextOverflow.ellipsis,
            //     //   style: Theme.of(context).textTheme.headline4,
            //     // ),
            //   ),
            // ),
            // SizedBox(height: 10),
            ListTile(
              onTap: () {
                // TESTT DISABLE/EDIT DEFAULT BEHAVIOR OF HELP AND SUPPORT
                // Navigator.of(context).pushNamed('/Languages1');
                launch('tel:+971557559471');
              },
              trailing: Icon(
                Icons.phone,
                color: Colors.green,
              ),
              title: Text(
                S.of(context).phone__support,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                // TESTT DISABLE/EDIT DEFAULT BEHAVIOR OF HELP AND SUPPORT
                // Navigator.of(context).pushNamed('/Languages1');
                // launch('tel:+971557559471');
                final Uri _emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@BaqalaApp.ae',
                    queryParameters: {
                      'subject': "Baqala App LLC Help & Support Query"
                    });
                launch(_emailLaunchUri.toString());
              },
              trailing: Icon(
                Icons.email,
                color: Colors.green,
              ),
              title: Text(
                S.of(context).email__support,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
