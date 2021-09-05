import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/translations/translations.provider.dart';

class LanguageButton extends ConsumerWidget {
  final String language;
  final bool selected;
  final Function onPressed;

  LanguageButton({this.language, this.selected = false, this.onPressed})
      : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary:
              selected ? Theme.of(context).buttonColor : Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.all(8)),
      child: _child(ref),
      onPressed: this.onPressed,
    );
  }

  Widget _child(WidgetRef ref) {
    final translations = ref.read(translationsProvider);
    if (translations.languageNames[language] != null) {
      return Text(translations.languageNames[language].toUpperCase());
    }
    String languageName = language.split('-').join('\n');
    return Text(languageName);
  }
}
