import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './screens/settings_screen.dart';
import './screens/friends_location_menu_screen.dart';
import './screens/manage_friend_list_screen.dart';
import './screens/loading_screen.dart';
import './screens/auth_screen.dart';
import './screens/welcome_screen.dart';
import './screens/control_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/add_place_screen.dart';
import './screens/pick_on_map_screen.dart';
import './screens/place_details_screen.dart';
import './screens/friends_location_screen.dart';
import './screens/pick_circle_screen.dart';
import './screens/add_track_place_screen.dart';
import './screens/permission_screen.dart';
import './screens/users_screen.dart';

void main() {
  runApp(Whereabouts());
}

class Whereabouts extends StatefulWidget {
  Whereabouts({Key key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) async {
    _WhereaboutsState state =
        context.findAncestorStateOfType<_WhereaboutsState>();
    state.changeLanguage(newLocale);
  }

  @override
  _WhereaboutsState createState() => _WhereaboutsState();
}

class _WhereaboutsState extends State<Whereabouts> {
  Locale _locale;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      DocumentSnapshot settings = await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('settings')
          .document(user.uid)
          .get();
      Locale prefferedLocale;
      if (settings['language'] == 'pl') {
        prefferedLocale = Locale('pl', 'PL');
      } else if (settings['language'] == 'en') {
        prefferedLocale = Locale('en', 'US');
      }
      setState(() {
        _locale = prefferedLocale;
      });
    }
  }

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whereabouts',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        backgroundColor: Colors.amber[600],
        accentColor: Colors.grey[900],
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.grey[900],
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('pl', 'PL'),
      ],
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
          if (locale == null) {
            locale = Localizations.localeOf(context);
          }
        }
        return supportedLocales.first;
      },
      home: StreamBuilder(
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            }
            if (userSnapshot.hasData) {
              return PermissionScreen();
            }
            return WelcomeScreen();
          },
          stream: FirebaseAuth.instance.onAuthStateChanged),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
        ControlScreen.routeName: (ctx) => ControlScreen(),
        WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
        EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
        AddPlaceScreen.routeName: (ctx) => AddPlaceScreen(),
        PickOnMapScreen.routeName: (ctx) => PickOnMapScreen(),
        PlaceDetailsScreen.routeName: (ctx) => PlaceDetailsScreen(),
        FriendsLocationScreen.routeName: (ctx) => FriendsLocationScreen(),
        PickCircleScreen.routeName: (ctx) => PickCircleScreen(),
        AddTrackPlaceScreen.routeName: (ctx) => AddTrackPlaceScreen(),
        PermissionScreen.routeName: (ctx) => PermissionScreen(),
        UsersScreen.routeName: (ctx) => UsersScreen(),
        ManageFriendListScreen.routeName: (ctx) => ManageFriendListScreen(),
        FriendsLocationMenuScreen.routeName: (ctx) =>
            FriendsLocationMenuScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
      },
    );
  }
}
