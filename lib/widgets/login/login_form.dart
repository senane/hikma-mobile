import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/colors.dart';

import 'login.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameNode = FocusNode();
  final _passwordNode = FocusNode();

  LoginBloc get _loginBloc => widget.loginBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (context, state) {
        if (state is LoginFailure) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
        return Form(
          child: Column(
            children: [
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
                  if (state is! LoginLoading) {
                    _onLoginButtonPressed();
                  }
                },
              ),
              state is LoginLoading
                  ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator())
              )
                  : ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    child: Text('LOGIN'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    color: hikmaPrimary,
                    textColor: Colors.white,
                    onPressed: () {
                      if (state is! LoginLoading) {
                        _onLoginButtonPressed();
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      _loginBloc.dispatch(LoginCancelled());
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    _passwordNode.unfocus();
    _loginBloc.dispatch(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }
}
