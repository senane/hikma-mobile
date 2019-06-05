import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:hikma_health/widgets/home/home.dart';

import 'login.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _authenticationBloc,
      listener: (context, state) {
        if (state is AuthenticationAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                HomeScreen(userRepository: _userRepository)),
          );
        }
      },
      child: Scaffold(
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
              LoginForm(
                authenticationBloc: _authenticationBloc,
                loginBloc: _loginBloc,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
