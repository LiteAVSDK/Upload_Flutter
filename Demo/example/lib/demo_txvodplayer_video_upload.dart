import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vod_upload_flutter/txugc_publish.dart';
import 'package:vod_upload_flutter/txugc_publish_type_def.dart';
import 'package:vod_upload_flutter/txugc_publish_log.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vod_upload_flutter_example/app_localizations.dart';

import 'demo_txvodplayer_file_item.dart';

const signature = "";

class DemoTXVodPlayerVideoUploadWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DemoTXVodPlayerVideoUploadState();
  }
}

class _DemoTXVodPlayerVideoUploadState
    extends State<DemoTXVodPlayerVideoUploadWidget>
    implements IPrepareUploadCallback, IUploadResumeController {
  final _mediaPicker = ImagePicker();

  List<FileItem> items = [];

  @override
  void initState() {
    TXUGCPublishLog.useDebug();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Text(
                    AppLocals.of(context).addVideo,
                    style: TextStyle(color: Color(0xFF0175C2), fontSize: 22),
                  ),
                  onTap: () async {
                    XFile? video = await getVideo();
                    if (video == null ||
                        StringUtils.isEmpty(video.path) ||
                        StringUtils.isEmpty(video.name)) {
                      EasyLoading.showError(AppLocals.of(context).noFileSelected);
                      return;
                    }
                    setState(() {
                      items.add(FileItem(
                        filePath: video.path,
                        fileName: video.name,
                        type: FileType.video,
                        signature: signature,
                      ));
                    });
                  },
                ),
                InkWell(
                  child: Text(
                    AppLocals.of(context).addMedia,
                    style: TextStyle(color: Color(0xFF0175C2), fontSize: 22),
                  ),
                  onTap: () async {
                    XFile? image = await getImage();
                    if (image == null ||
                        StringUtils.isEmpty(image.path) ||
                        StringUtils.isEmpty(image.name)) {
                      EasyLoading.showError(AppLocals.of(context).noFileSelected);
                      return;
                    }
                    setState(() {
                      items.add(FileItem(
                        filePath: image.path,
                        fileName: image.name,
                        type: FileType.image,
                        signature: signature,
                      ));
                    });
                  },
                ),
                InkWell(
                  child: Text(
                    AppLocals.of(context).clearPanel,
                    style: TextStyle(color: Color(0xFF0175C2), fontSize: 22),
                  ),
                  onTap: () async {
                    items.forEach((element) {
                      element.clearItem();
                    });
                    setState(() {
                      items = [];
                    });
                  },
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
            ),
            InkWell(
              child: Text(
                AppLocals.of(context).prepareUpload,
                style: TextStyle(color: Color(0xFF0175C2), fontSize: 22),
              ),
              onTap: () async {
                TXUGCPublish.prepareUpload(signature, this);
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: items[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<XFile?> getVideo() async {
    return await _mediaPicker.pickVideo(source: ImageSource.gallery);
  }

  Future<XFile?> getImage() async {
    return await _mediaPicker.pickImage(source: ImageSource.gallery);
  }

  @override
  void onFinish() {
    EasyLoading.dismiss();
    EasyLoading.showToast(AppLocals.of(context).prepareUploadSuccess);
  }

  @override
  void onLoading() {
    EasyLoading.show();
  }

  Map<String, String> map = {};

  @override
  void clearLocalCache() {
    print("flutter: clearLocalCache");
  }

  @override
  ResumeCacheData getResumeData(String filePath) {
    print("flutter: getResumeData");
    var data = ResumeCacheData();
    return data;
  }

  @override
  bool isResumeUploadVideo(String uploadId, TVCUploadInfo uploadInfo,
      String vodSessionKey, int fileLastModTime, int coverFileLastModTime) {
    print("flutter: isResumeUploadVideo");
    return true;
  }

  @override
  void saveSessionAndroid(String filePath, String vodSessionKey,
      String uploadId, TVCUploadInfo uploadInfo) {
    print("flutter: saveSessionAndroid");
  }

  @override
  void saveSessionIOS(String filePath, String vodSessionKey,
      Uint8List resumeData, TVCUploadInfo uploadInfo) {
    print("flutter: saveSessionIOS");
  }
}

class StringUtils {
  static bool isEmpty(String? str) {
    return str?.isEmpty ?? true;
  }

  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }
}
