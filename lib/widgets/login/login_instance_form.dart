import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/colors.dart';

import 'login.dart';

class LoginInstanceForm extends StatefulWidget {
  final LoginBloc loginBloc;

  LoginInstanceForm({
    Key key,
    @required this.loginBloc,
  }) : super(key: key);

  @override
  State<LoginInstanceForm> createState() => _LoginInstanceFormState();
}

class _LoginInstanceFormState extends State<LoginInstanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _instanceController = TextEditingController();
  final _instanceNode = FocusNode();

  LoginBloc get _loginBloc => widget.loginBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Container(
                    width: 50,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: _instanceController,
                      decoration: InputDecoration(
                        hintText: 'Instance',
                      ),
                      focusNode: _instanceNode,
                      validator: (value) {
                        return value.isEmpty
                            ? 'This field cannot be empty'
                            : null;
                      },
                      textAlign: TextAlign.right,
                      onFieldSubmitted: (instance) {
                        _instanceNode.unfocus();
                      },
                    ),
                  ),
                  Text('.hikmahealth.org'),
                  Container(
                    width: 50,
                  )
                ],
              ),
              SizedBox(height: 16),
              state is LoginInstanceLoading
                  ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator())
              )
                  : ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    child: Text('CHOOSE'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    color: hikmaPrimary,
                    textColor: Colors.white,
                    onPressed: () {
                      if (state is! LoginInstanceLoading) {
                        _onChooseInstancePressed();
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () {
                      _loginBloc.dispatch(LoginCancelled());
                    },
                  ),
                  Container(
                    width: 50,
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _onChooseInstancePressed() {
    if (_formKey.currentState.validate()) {
      _instanceNode.unfocus();
      String apiBase = 'https://${_instanceController.text}'
          '.hikmahealth.org/openmrs/ws/rest/v1';
      _loginBloc.dispatch(LoginInstanceChosen(
        apiBase: apiBase,
      ));
    }
  }
}
