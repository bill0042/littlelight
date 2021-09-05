import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/translations/translations.consumer.dart';

typedef ExtractTextFromData = String Function(dynamic data);

class TranslatedTextWidget extends ConsumerStatefulWidget {
  final String text;
  final String language;
  final Map<String, String> replace;
  final bool uppercase;
  final int maxLines;
  final TextOverflow overflow;
  final String semanticsLabel;
  final bool softWrap;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double textScaleFactor;

  TranslatedTextWidget(this.text,
      {Key key,
      this.replace = const {},
      this.language,
      this.maxLines,
      this.overflow,
      this.semanticsLabel,
      this.softWrap,
      this.style,
      this.textAlign,
      this.textDirection,
      this.textScaleFactor,
      this.uppercase = false})
      : super(key: key ?? Key(text));

  @override
  createState() {
    return TranslatedTextWidgetState();
  }
}

class TranslatedTextWidgetState extends ConsumerState<TranslatedTextWidget>
    with TranslationsConsumerState {
  String translatedText;
  @override
  void initState() {
    super.initState();
    loadTranslation();
  }

  Future<void> loadTranslation() async {
    if (widget.language != null) {
      translatedText = await translations.getTranslation(widget.text,
          replace: widget.replace, languageCode: widget.language);
    } else {
      translatedText = await translations.getTranslation(widget.text,
          replace: widget.replace);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = "";
    if (translatedText != null) {
      text = translatedText;
    }
    if (widget.uppercase) {
      text = text.toUpperCase();
    }
    return Text(text,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        semanticsLabel: widget.semanticsLabel,
        softWrap: widget.softWrap,
        style: widget.style,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        textScaleFactor: widget.textScaleFactor,
        key: Key(text));
  }
}
