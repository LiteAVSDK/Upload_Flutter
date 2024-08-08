import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vod_upload_flutter_example/demo_txvodplayer_video_upload.dart';
import 'package:vod_upload_flutter_example/app_localization_delegate.dart';

void main() {
  runApp(MaterialApp(
    localizationsDelegates: [
      AppLocalizationDelegate.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ],
    home: DemoTXVodPlayerVideoUploadWidget(),
    builder: EasyLoading.init(),
  ));
}
