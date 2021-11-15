import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/translations/translations.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:timeago/timeago.dart' as timeago;

typedef ExtractTextFromData = String Function(dynamic data);

class ExpiryDateWidget extends ConsumerStatefulWidget {
  final String date;
  final double fontSize;
  ExpiryDateWidget(this.date, {Key key, this.fontSize = 12}) : super(key: key);

  @override
  createState() {
    return ExpiryDateWidgetState();
  }
}

class ExpiryDateWidgetState extends ConsumerState<ExpiryDateWidget>
    with TranslationsConsumerState {
  bool expired = false;
  String expiresIn = "";

  @override
  void initState() {
    super.initState();
    updateDuration();
  }

  updateDuration() async {
    var expiry = DateTime.parse(widget.date);
    expired = DateTime.now().toUtc().isAfter(expiry);
    if (expired) {
      setState(() {});
      return;
    }
    var locale = translations.currentLanguage;
    expiresIn = timeago.format(expiry, allowFromNow: true, locale: locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
        color: Colors.red.shade300,
        fontSize: widget.fontSize,
        fontStyle: FontStyle.italic);
    if (expired) {
      return TranslatedTextWidget(
        "Expired",
        style: style,
      );
    }
    return TranslatedTextWidget(
      "Expires {timeFromNow}",
      replace: {'timeFromNow': expiresIn},
      key: Key(expiresIn),
      style: style,
    );
  }
}
