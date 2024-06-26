import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/ui/timed_updater.widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinycolor2/tinycolor2.dart';

class ExpiryDateWidget extends StatelessWidget {
  final String date;
  final TextStyle? style;
  final Duration? autoUpdateEvery;
  const ExpiryDateWidget(this.date, {Key? key, this.style, this.autoUpdateEvery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(this.date);
    if (date == null) return Container();
    final autoUpdate = this.autoUpdateEvery;
    if (autoUpdate != null) {
      return TimedUpdater(every: autoUpdate, child: buildContent(context, date));
    }
    return buildContent(context, date);
  }

  Widget buildContent(BuildContext context, DateTime parsedDate) {
    final now = DateTime.now().toUtc();
    final isExpired = parsedDate.isBefore(now);
    if (isExpired) {
      return buildField(context, "Expired", true);
    }

    final difference = parsedDate.difference(now);
    final expiresIn = timeago.format(parsedDate, allowFromNow: true);
    bool willExpireSoon =
        difference.inMilliseconds < context.watch<UserSettingsBloc>().questExpirationWarningThreshold.inMilliseconds;
    return buildField(
      context,
      "Expires {timeFromNow}".translate(context, replace: {'timeFromNow': expiresIn}),
      willExpireSoon,
    );
  }

  Widget buildField(BuildContext context, String text, bool warning) {
    final warningColor = context.theme.errorLayers.layer3.mix(context.theme.surfaceLayers, 30);
    final warningTextColor = context.theme.errorLayers.layer3.mix(context.theme.onSurfaceLayers, 30);

    final style = (this.style ?? context.textTheme.caption)
        .copyWith(color: warning ? context.theme.onSurfaceLayers : warningTextColor);
    final field = Text(
      text,
      style: style,
    );
    if (!warning) return field;
    return Container(
      padding: EdgeInsets.all(2).copyWith(right: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: warningColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.clock,
            size: style.fontSize,
          ),
          SizedBox(width: 2),
          field,
        ],
      ),
    );
  }
}
