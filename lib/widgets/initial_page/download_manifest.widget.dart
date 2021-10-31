import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

typedef OnFinishCallback = void Function();

class DownloadManifestWidget extends ConsumerStatefulWidget {
  final String title = "Download Database";
  final String selectedLanguage;
  final OnFinishCallback onFinish;
  DownloadManifestWidget({this.selectedLanguage, this.onFinish});

  @override
  DownloadManifestWidgetState createState() {
    return DownloadManifestWidgetState();
  }
}

class DownloadManifestWidgetState extends ConsumerState<DownloadManifestWidget>
    with ManifestConsumerState {
  double _downloadProgress = 0;
  int _loaded = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    if (_downloadProgress == 0) {
      this.download();
    }
  }

  void download() async {
    bool result = await manifest.download(onProgress: (loaded, total) {
      setState(() {
        _downloadProgress = loaded / total;
        _loaded = (loaded / 1024).floor();
        _total = (total / 1024).floor();
      });
    });

    if (result) {
      this.widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        LinearProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          value: (_downloadProgress != null && _downloadProgress < 1)
              ? _downloadProgress
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _downloadProgress < 0.99
                ? TranslatedTextWidget(
                    "Downloading",
                    key: Key("downloading"),
                  )
                : TranslatedTextWidget("Uncompressing", key: Key("unzipping")),
            Text("$_loaded/${_total}KB")
          ],
        )
      ],
    );
  }
}
