// Copyright (c) 2022 Tencent. All rights reserved.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Load text resource internationalization
/// 文本资源国际化加载
class AppLocals {
  final Locale locale;

  static AppLocals? _current;

  static AppLocals get current {
    assert(_current != null, 'No instance of AppLocals was loaded. '
        'Try to initialize the AppLocals delegate before accessing AppLocals.current.');
    return _current!;
  }

  AppLocals(this.locale);

  static AppLocals of(BuildContext context) {
    final instance = AppLocals.maybeOf(context);
    assert(instance != null,
    'No instance of AppLocals present in the widget tree. Did you add AppLocalizationDelegate in localizationsDelegates?');
    return instance!;
  }

  static Map<String, String> _localStrings = {};

  static AppLocals? maybeOf(BuildContext context) {
    return Localizations.of<AppLocals>(context, AppLocals);
  }

  static Future<AppLocals> loadJson(Locale locale) async {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    AppLocals appLocals = AppLocals(locale);
    await appLocals.loadIntl(name);
    AppLocals._current = appLocals;
    return appLocals;
  }

  Future<void> loadIntl(String currentLanguageName) async {
    final jsonString = await rootBundle.loadString("assets/json/i18n.json");
    Map<String, dynamic> map = json.decode(jsonString);
    Map<String, Map<String, String>> parentMap = map.map((key, value) => MapEntry(key, value.cast<String, String>()));
    Map<String, String>? tmpLocal = parentMap[currentLanguageName];
    _localStrings = tmpLocal ?? {};
  }

  String? findStr(String key) => _localStrings[key];

  String get startUpload => _localStrings["start_upload"]!;
  String get noFileSelected => _localStrings["no_file_selected"]!;
  String get signatureIsNull => _localStrings["signature_is_null"]!;
  String get videoPathIsNull => _localStrings["video_path_is_null"]!;
  String get fileNotExist => _localStrings["file_not_exist"]!;
  String get hasFileUploading => _localStrings["has_file_uploading"]!;
  String get uploadParamInvalid => _localStrings["upload_param_invalid"]!;
  String get cancelUpload => _localStrings["cancel_upload"]!;
  String get resumeUpload => _localStrings["resume_upload"]!;
  String get getStatusInfo => _localStrings["get_status_info"]!;
  String get addCoverImage => _localStrings["add_cover_image"]!;
  String get addCoverImageSuccess => _localStrings["add_cover_image_success"]!;
  String get infoNotObtained => _localStrings["info_not_obtained"]!;

  String get addVideo => _localStrings["add_video"]!;
  String get addMedia => _localStrings["add_media"]!;
  String get clearPanel => _localStrings["clear_panel"]!;
  String get prepareUpload => _localStrings["prepare_upload"]!;
  String get prepareUploadSuccess => _localStrings["prepare_upload_success"]!;
}
