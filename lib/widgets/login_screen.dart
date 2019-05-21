import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/network/network_calls.dart';
import 'package:hikma_health/widgets/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false, _firstTime = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameNode = FocusNode();
  final _passwordNode = FocusNode();
  final _secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      _autoAuthenticate();
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: <Widget>[
            SizedBox(height: 32),
            Column(
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
                  child: ImageIcon(
                    AssetImage('assets/logo.png'),
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Hikma Health',
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
                Text(
                  'Smart care, everywhere.',
                  style: TextStyle(
                      fontSize: 16
                  ),
                )
              ],
            ),
            SizedBox(height: 96),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
              focusNode: _usernameNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (username) {
                _usernameNode.unfocus();
                FocusScope.of(context).requestFocus(_passwordNode);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              focusNode: _passwordNode,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (password) {
                _passwordNode.unfocus();
                _login();
              },
            ),
            _loading
                ? Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                )
            )
                : ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                ),
                RaisedButton(
                  child: Text('LOGIN'),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)
                  ),
                  color: hikmaPrimary,
                  textColor: Colors.white,
                  onPressed: () {
                    _login();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void _autoAuthenticate() async {
    setState(() => _loading = true);
    _firstTime = false;
    String basicAuth = await _secureStorage.read(key: 'auth');
    if (basicAuth != null) {
      String sessionId = await baseAuthenticate(basicAuth: basicAuth);
      setState(() => _loading = false);
      if (sessionId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientSearchScreen()),
        );
      }
    }
    setState(() => _loading = false);
  }

  void _login() async {
    setState(() => _loading = true);
    String username = _usernameController.text;
    String password = _passwordController.text;
    String sessionId = await authenticate(username: username, password: password);
    setState(() => _loading = false);
    if (sessionId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientSearchScreen()),
      );
    }
  }
}
