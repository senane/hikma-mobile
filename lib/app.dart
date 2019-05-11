import 'package:flutter/material.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/widgets/login_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData buildTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      primaryColor: hikmaPrimary,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)),
          gapPadding: 10,
        ),
      ),

      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
    );
  }

  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        fontWeight: FontWeight.w900
      ),
      title: base.title.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500
      ),
      caption: base.caption.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
    );
  }
}

