// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:just_chat_app/pages/auth_page.dart';
import 'package:just_chat_app/pages/rooms_page.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    Key? key,
    required this.mode,
  }) : super(key: key);
  final bool mode;

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    getInitialSession();
    super.initState();
  }

  Future<void> getInitialSession() async {
    await Future.delayed(Duration.zero);

    try {
      final session = await SupabaseAuth.instance.initialSession;
      final user = session?.user;
      if (session == null) {
        if (user != null) {
          Navigator.of(context).pushReplacementNamed(
            RoomsPage.ruta,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
            AuthPage.ruta,
          );
        }
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          RoomsPage.route(),
          (_) => false,
        );
      }
    } catch (_) {
      context.showErrorSnackBar(
        message: 'Error occured during session refresh',
      );
      Navigator.of(context).pushAndRemoveUntil(
        AuthPage.route(widget.mode),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: preloader,
    );
  }
}
