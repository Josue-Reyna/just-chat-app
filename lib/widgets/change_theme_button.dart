import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_chat_app/provider/theme_provider.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Icon(
          themeProvider.isLightMode ? Icons.light_mode : Icons.dark_mode,
          semanticLabel: 'Change mode',
        ),
        Switch.adaptive(
          value: themeProvider.isLightMode,
          onChanged: (value) {
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            provider.toggleTheme(value);
          },
        ),
      ],
    );
  }
}
