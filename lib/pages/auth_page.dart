// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:just_chat_app/generated/l10n.dart';
import 'package:just_chat_app/pages/rooms_page.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:just_chat_app/widgets/change_language_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    Key? key,
    required this.mode,
  }) : super(key: key);
  final bool mode;

  static String ruta = '/login';

  static Route<void> route(bool mode) {
    return MaterialPageRoute(
      builder: (context) => AuthPage(
        mode: mode,
      ),
    );
  }

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _seePassword = false;
  bool isHover1 = false;
  bool isHover2 = false;
  bool _isLogin = false;
  final int random = Random().nextInt(4);

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    bool haveNavigated = false;
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null && !haveNavigated) {
        haveNavigated = true;
        Navigator.of(context).pushReplacement(RoomsPage.route());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _authSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  Future<void> _signIn() async {
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: 'unexpectedErrorMessage');
    }
  }

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    final color = Random().nextInt(8);
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'color': color,
        },
      );
      context.showSnackBar(
        message: S.of(context).registerMessage,
        backgroundColor: checkColor,
      );
    } on AuthException catch (error) {
      context.showErrorSnackBar(
        message: error.toString(),
      );
    } catch (error) {
      context.showErrorSnackBar(message: 'unexpectedErrorMessage');
    }
  }

  List<Color> getColors() {
    switch (random) {
      case 0:
        return themeColors.sublist(0, 2);
      case 1:
        return themeColors.sublist(2, 4);
      case 2:
        return themeColors.sublist(4, 6);
      case 3:
        return themeColors.sublist(5, 7);
      default:
        return themeColors;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: const ChangeLanguage(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: _Piet(colors: getColors())),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Just Chat',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: size.width < 600 ? 100 : size.width * 0.3,
                    ),
                    child: Column(
                      children: [
                        height2,
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            labelStyle: TextStyle(
                              color: widget.mode ? black : white,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: widget.mode ? black : white,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: widget.mode ? black : white,
                                width: 5,
                              ),
                            ),
                            focusColor: widget.mode ? black : white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: widget.mode ? black : white,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (val) =>
                              val != null && !EmailValidator.validate(val)
                                  ? S.current.requiredMessage
                                  : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        height2,
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_seePassword,
                          decoration: InputDecoration(
                            label: Text(S.of(context).password),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() {
                                _seePassword = !_seePassword;
                              }),
                              icon: Icon(
                                !_seePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: widget.mode ? black : white,
                              ),
                              tooltip: !_seePassword
                                  ? S.of(context).seePassword
                                  : S.of(context).hidePassword,
                            ),
                            labelStyle: TextStyle(
                              color: widget.mode ? black : white,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: widget.mode ? black : white,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: widget.mode ? black : white,
                                width: 5,
                              ),
                            ),
                            focusColor: widget.mode ? black : white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: widget.mode ? black : white,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return S.of(context).requiredMessage;
                            }
                            if (val.length < 6) {
                              return S.of(context).passwordLength;
                            }
                            return null;
                          },
                        ),
                        height2,
                        if (!_isLogin)
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              label: Text(S.of(context).username),
                              labelStyle: TextStyle(
                                color: widget.mode ? black : white,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: widget.mode ? black : white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: widget.mode ? black : white,
                                  width: 5,
                                ),
                              ),
                              focusColor: widget.mode ? black : white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: widget.mode ? black : white,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return S.of(context).requiredMessage;
                              }
                              final isValid =
                                  RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                              if (!isValid) {
                                return S.of(context).usernameRequired;
                              }
                              return null;
                            },
                          ),
                        if (!_isLogin) height2,
                        height2,
                        ElevatedButton(
                          onHover: (value) => setState(() {
                            isHover1 = value;
                          }),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: widget.mode
                                ? !isHover1
                                    ? black
                                    : white
                                : isHover1
                                    ? black
                                    : white,
                            foregroundColor: widget.mode
                                ? !isHover1
                                    ? white
                                    : black
                                : isHover1
                                    ? white
                                    : black,
                          ),
                          onPressed: !_isLogin ? _signUp : _signIn,
                          child: Text(
                            !_isLogin
                                ? S.of(context).registerButton
                                : S.of(context).loginButton,
                          ),
                        ),
                        height2,
                        ElevatedButton(
                          onHover: (value) => setState(() {
                            isHover2 = value;
                          }),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: widget.mode
                                ? !isHover2
                                    ? black
                                    : white
                                : isHover2
                                    ? black
                                    : white,
                            foregroundColor: widget.mode
                                ? !isHover2
                                    ? white
                                    : black
                                : isHover2
                                    ? white
                                    : black,
                          ),
                          onPressed: () => setState(() {
                            _isLogin = !_isLogin;
                          }),
                          child: Text(
                            _isLogin
                                ? S.of(context).registerButton
                                : S.of(context).loginButton,
                          ),
                        ),
                        height2,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

class _Piet extends StatelessWidget {
  const _Piet({
    required this.colors,
  });
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
      gridDelegate: SliverStairedGridDelegate(
        crossAxisSpacing: 48,
        mainAxisSpacing: 24,
        startCrossAxisDirectionReversed: true,
        pattern: const [
          StairedGridTile(0.5, 1),
          StairedGridTile(0.5, 3 / 4),
          StairedGridTile(1.0, 10 / 4),
        ],
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
                tileMode: TileMode.mirror,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
