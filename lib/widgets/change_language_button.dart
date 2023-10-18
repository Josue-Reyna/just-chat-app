import 'package:flutter/material.dart';
import 'package:just_chat_app/generated/l10n.dart';
import 'package:just_chat_app/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton(
        onPressed: () => languageProvider.changeLanguage(),
        icon: const Icon(
          Icons.language,
          size: 24,
        ),
        tooltip: S.of(context).changeLanguage,
      ),
    );
  }
}
