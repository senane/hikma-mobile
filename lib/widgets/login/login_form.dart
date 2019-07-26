import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/authentication/authentication.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/model/location.dart';

import 'login.dart';
import 'login_instance_form.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameNode = FocusNode();
  final _passwordNode = FocusNode();

  bool _errorAlreadyDisplayed = false;

  LoginBloc get _loginBloc => widget.loginBloc;

  List<Location> _locations;
  Location _location;
  String _instance;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (context, state) {
        if (state is LoginStarting) {
          _loginBloc.dispatch(LoginStarted());
          return Padding(
              padding: EdgeInsets.only(top: 128),
              child: Center(child: CircularProgressIndicator())
          );
        } else if (state is LoginFailure && !_errorAlreadyDisplayed) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
          _errorAlreadyDisplayed = true;
        } else if (state is LoginChooseInstance
            || state is LoginInstanceLoading
            || state is LoginInstanceFailure) {
          return LoginInstanceForm(loginBloc: _loginBloc,);
        } else if (state is LoginCredentials) {
          _locations = state.locations;
          _instance = state.instance;
        }
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Sign in to $_instance'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
                focusNode: _usernameNode,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return value.isEmpty
                      ? 'This field cannot be empty'
                      : null;
                },
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
                validator: (value) {
                  return value.isEmpty
                      ? 'This field cannot be empty'
                      : null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField(
                  value: _location,
                  items: _locations.map((Location location) {
                    return new DropdownMenuItem<Location>(
                      child: new Text(location.name),
                      value: location,
                    );
                  }).toList(),
                  onChanged: (Location value) {
                    setState(() => _location = value);
                  },
                  hint: Text('Location'),
                  validator: (value) {
                    return value == null
                        ? 'This field cannot be empty'
                        : null;
                  }
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
                        _errorAlreadyDisplayed = false;
                        _onLoginButtonPressed();
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('CHANGE INSTANCE'),
                    onPressed: () {
                      _loginBloc.dispatch(LoginStarted());
                    },
                  ),
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
    if (_formKey.currentState.validate()) {
      _passwordNode.unfocus();
      _loginBloc.dispatch(LoginButtonPressed(
        username: _usernameController.text,
        password: _passwordController.text,
        location: _location,
      ));
    }
  }
}
