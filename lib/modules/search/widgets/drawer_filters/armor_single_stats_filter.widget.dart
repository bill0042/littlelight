import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/armor_stats_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/armor_single_stats_filter_options.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:bungie_api/src/models/destiny_stat_definition.dart';
import 'base_drawer_filter.widget.dart';

class ArmorSingleStatsFilterWidget extends BaseDrawerFilterWidget<ArmorSingleStatsFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Stats".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ArmorSingleStatsFilterOptions data) {
    final availableEntries = data.availableValues.entries;
    final entries = availableEntries
        .map(
          (e) => (
            statHash: e.key,
            available: e.value,
            value: data.value[e.key] ?? ArmorStatsConstraints(min: e.value.min, max: e.value.max),
          ),
        )
        .toList();
    const rowHeight = 36.0;
    const rowSpacing = 4.0;
    final bgColor = context.theme.surfaceLayers.layer3;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          Column(
            spacing: rowSpacing,
            children: [
              for (final entry in entries)
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                  height: rowHeight,
                  width: rowHeight,
                  padding: const EdgeInsets.all(4),
                  child: ManifestImageWidget<DestinyStatDefinition>(entry.statHash),
                ),
            ],
          ),
          IntrinsicWidth(
            child: Column(
              spacing: rowSpacing,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in entries)
                  Container(
                    height: rowHeight,
                    alignment: Alignment.centerRight,
                    color: bgColor,
                    child: Text("${entry.available.min.ceil()}", textAlign: TextAlign.end),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              spacing: rowSpacing,
              children: [
                for (final entry in entries)
                  Container(
                    height: rowHeight,
                    color: bgColor,
                    child: StatSliderWidget(
                      available: entry.available,
                      value: entry.value,
                      values: data.value,
                      update: update,
                    ),
                  ),
              ],
            ),
          ),
          IntrinsicWidth(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in entries)
                  Container(
                    height: rowHeight,
                    alignment: Alignment.centerRight,
                    color: bgColor,
                    padding: const EdgeInsets.only(right: 4),
                    child: Text("${entry.available.max.ceil()}", textAlign: TextAlign.end),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatSliderWidget extends StatelessWidget {
  final ArmorStatsConstraints available;
  final ArmorStatsConstraints value;
  final ArmorStatsConstraintsMap values;
  final void Function(BuildContext, ArmorSingleStatsFilterOptions) update;

  const StatSliderWidget({
    super.key,
    required this.available,
    required this.value,
    required this.values,
    required this.update,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setLocalState) {
        final double min = value.min.toDouble();
        final double max = value.max.toDouble();
        return RangeSlider(
          values: RangeValues(min, max),
          min: available.min.toDouble(),
          max: available.max.toDouble(),
          labels: RangeLabels(
            min.ceil().toString(),
            max.ceil().toString(),
          ),
          divisions: available.max - available.min,
          onChanged: (RangeValues range) {
            setLocalState(() {
              value.min = range.start.toInt();
              value.max = range.end.toInt();
            });
          },
          onChangeEnd: (RangeValues range) {
            value.min = range.start.toInt();
            value.max = range.end.toInt();
            update(
              context,
              ArmorSingleStatsFilterOptions(values),
            );
            value.min = range.start.toInt();
            value.max = range.end.toInt();
            update(context, ArmorSingleStatsFilterOptions(values));
          },
        );
      },
    );
  }
}
