import 'dart:io';

import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../pickers/user_image_picker.dart';
import './auth_google.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading, this.isLogin);

  final bool isLogin;
  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  File _userImageFile;
  bool _passwordHidden = true;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('auth_form', 'pick_image_error'),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName,
        _userImageFile,
        _isLogin,
        context,
      );
      // send request to firebase
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.amber[500],
            Colors.amber[800],
          ],
        ),
      ),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _isLogin
                            ? AppLocalizations.of(context)
                                .translate('auth_form', 'log_in')
                            : AppLocalizations.of(context)
                                .translate('auth_form', 'sign_up'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GoogleAuth(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('auth_form', 'or'),
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (!_isLogin) UserImagePicker(_pickedImage),
                    TextFormField(
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      key: ValueKey('email'),
                      validator: (value) {
                        if (value.isEmpty ||
                            !value.contains('@') ||
                            value.length < 4 ||
                            value.contains(' ')) {
                          return AppLocalizations.of(context)
                              .translate('auth_form', 'please_enter_email');
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('auth_form', 'email_address'),
                        labelStyle: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                    if (!_isLogin)
                      TextFormField(
                        autocorrect: false,
                        textCapitalization: TextCapitalization.words,
                        enableSuggestions: false,
                        key: ValueKey('userName'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 4) {
                            return AppLocalizations.of(context)
                                .translate('auth_form', 'enter_characters');
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('auth_form', 'username'),
                          labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        onSaved: (value) {
                          _userName = value;
                        },
                      ),
                    TextFormField(
                      key: ValueKey('password'),
                      obscureText: _passwordHidden,
                      validator: (value) {
                        if (value.isEmpty || value.length < 7) {
                          return AppLocalizations.of(context)
                              .translate('auth_form', 'password_length');
                        } else if (value.contains(' ')) {
                          return AppLocalizations.of(context)
                              .translate('auth_form', 'password_space');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                              .translate('auth_form', 'password'),
                        labelStyle: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordHidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordHidden = !_passwordHidden;
                            });
                          },
                        ),
                      ),
                      onSaved: (value) {
                        _userPassword = value;
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('auth_form', 'password_length_space'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (widget.isLoading) CircularProgressIndicator(),
                    if (!widget.isLoading)
                      RaisedButton(
                        child: Text(
                          _isLogin
                              ? AppLocalizations.of(context)
                                  .translate('auth_form', 'log_in')
                              : AppLocalizations.of(context)
                                  .translate('auth_form', 'sign_up'),
                        ),
                        onPressed: _trySubmit,
                      ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          _isLogin
                              ? AppLocalizations.of(context)
                                  .translate('auth_form', 'dont_have_account')
                              : AppLocalizations.of(context)
                                  .translate('auth_form', 'have_account'),
                          textAlign: TextAlign.center,
                        ),
                        FlatButton(
                          child: Text(
                            _isLogin
                                ? AppLocalizations.of(context)
                                    .translate('auth_form', 'create_account')
                                : AppLocalizations.of(context)
                                    .translate('auth_form', 'log_in_now'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).backgroundColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
