import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.consumer.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

typedef ExtractUrlFromData<T> = String Function(T definition);

class ManifestImageWidget<T> extends ConsumerStatefulWidget {
  final int hash;
  final ExtractUrlFromData<T> urlExtractor;

  final Widget placeholder;

  final BoxFit fit;
  final Alignment alignment;

  ManifestImageWidget(this.hash,
      {Key key,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.urlExtractor,
      this.placeholder})
      : super(key: key);

  @override
  createState() {
    return ManifestImageState<T>();
  }
}

class ManifestImageState<T> extends ConsumerState<ManifestImageWidget<T>>
    with BungieApiConfigConsumerState, ManifestConsumerState {
  T definition;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  Future<void> loadDefinition() async {
    definition = await manifest.getDefinition<T>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Shimmer shimmer = ShimmerHelper.getDefaultShimmer(context);
    if (definition == null) return shimmer;
    String url = "";
    try {
      if (widget.urlExtractor == null) {
        url = (definition as dynamic).displayProperties.icon;
      } else {
        url = widget.urlExtractor(definition);
      }
    } catch (e) {
      print(e);
    }
    if (url == null || url.length == 0) {
      return shimmer;
    }
    return QueuedNetworkImage(
      imageUrl: apiConfig.bungieUrl(url),
      fit: widget.fit,
      alignment: widget.alignment,
      placeholder: widget.placeholder ?? shimmer,
      fadeInDuration: Duration(milliseconds: 300),
    );
  }
}
