import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_chat_app/cubits/profiles/profiles_cubit.dart';
import 'package:just_chat_app/generated/l10n.dart';
import 'package:just_chat_app/l10n/l10n.dart';
import 'package:just_chat_app/pages/auth_page.dart';
import 'package:just_chat_app/pages/rooms_page.dart';
import 'package:just_chat_app/provider/theme_provider.dart';
import 'package:just_chat_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:just_chat_app/pages/splash_page.dart';

class JustChat extends StatelessWidget {
  const JustChat({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        builder: (context, _) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return BlocProvider(
            create: (context) => ProfilesCubit(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Just Chat',
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                brightness: themeProvider.isLightMode
                    ? Brightness.light
                    : Brightness.dark,
                fontFamily: 'Gilroy-ExtraBold',
                dialogBackgroundColor:
                    themeProvider.isLightMode ? white : black,
                scaffoldBackgroundColor:
                    themeProvider.isLightMode ? white : black,
                primaryColorLight: themeProvider.isLightMode ? white : black,
                primaryColorDark: themeProvider.color,
                appBarTheme: AppBarTheme(
                  centerTitle: true,
                  elevation: 1,
                  backgroundColor: themeProvider.color,
                  iconTheme: IconThemeData(
                    color: themeProvider.isLightMode ? black : white,
                  ),
                  titleTextStyle: TextStyle(
                    color: themeProvider.isLightMode ? black : white,
                    fontSize: 18,
                    fontFamily: 'Gilroy-ExtraBold',
                  ),
                ),
                primaryColor: themeProvider.color,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: themeProvider.color,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    foregroundColor: themeProvider.isLightMode ? black : white,
                    backgroundColor: themeProvider.color,
                  ),
                ),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  color: themeProvider.color,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  floatingLabelStyle: TextStyle(
                    color:
                        themeProvider.isLightMode ? themeProvider.color : black,
                    backgroundColor:
                        themeProvider.isLightMode ? null : themeProvider.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeProvider.isLightMode
                          ? Colors.grey[600]!
                          : Colors.grey,
                      width: 5,
                    ),
                  ),
                  focusColor: themeProvider.color,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeProvider.color,
                      width: 2,
                    ),
                  ),
                ),
              ),
              locale: Locale(themeProvider.whatLanguage),
              supportedLocales: L10n.all,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routes: {
                '/': (context) => SplashPage(mode: themeProvider.isLightMode),
                AuthPage.ruta: (context) =>
                    AuthPage(mode: themeProvider.isLightMode),
                RoomsPage.ruta: (context) => const RoomsPage(),
              },
              initialRoute: '/',
            ),
          );
        },
      );
}
