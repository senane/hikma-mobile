import 'package:flutter/material.dart';
import 'package:hikma_health/colors.dart';

class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  hikmaPrimaryLight,
                  hikmaPrimary,
                  hikmaPrimaryDark
                ],
              ).createShader(bounds);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ImageIcon(
                AssetImage('assets/logo.png'),
                size: 72,
                color: Colors.white,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Text(
                'Hikma Health',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),
              ),
              Text(
                'Smart care, everywhere.',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
