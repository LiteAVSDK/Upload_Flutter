import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vod_upload_flutter/txugc_publish.dart';
import 'package:vod_upload_flutter/txugc_publish_type_def.dart';
import 'package:uuid/uuid.dart';
import 'package:vod_upload_flutter_example/app_localizations.dart';

import 'demo_string_utils.dart';

enum FileType { video, image }

class FileItem extends StatefulWidget {
  String filePath;

  String fileName;

  FileType type;

  String signature;

  FileItem({
    required this.filePath,
    required this.fileName,
    required this.type,
    required this.signature,
  });

  late _IFileItemState state;

  @override
  State<StatefulWidget> createState() {
    switch (type) {
      case FileType.video:
        state = _VideoItemState();
        break;
      case FileType.image:
        state = _ImageItemState();
        break;
    }
    return state;
  }

  void clearItem() {
    state.clearItem();
  }
}

class _VideoItemState extends _IFileItemState {
  String? _coverPath;

  ImagePicker _mediaPicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    uploader.setVideoListener(this);
  }

  @override
  Widget build(BuildContext context) {
    Widget fileItem = super.build(context);
    return Column(
      children: [
        fileItem,
        Container(
          margin: const EdgeInsets.only(top: 10),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              child: Text(
                AppLocals.of(context).addCoverImage,
                style: TextStyle(color: Color(0xFF0175C2), fontSize: 18),
              ),
              onTap: () async {
                XFile? image = await getImage();
                if (image == null ||
                    StringUtils.isEmpty(image.path) ||
                    StringUtils.isEmpty(image.name)) {
                  EasyLoading.showError(AppLocals.of(context).noFileSelected);
                  return;
                }
                _coverPath = image.path;
                EasyLoading.showToast(AppLocals.of(context).addCoverImageSuccess);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> pause() async {
    return await pauseUploadVideo();
  }

  @override
  Future<int> publish() async {
    return await publishVideo();
  }

  @override
  Future<int> resume() async {
    return await resumeUploadVideo();
  }

  @override
  Future<void> cancel() async {
    return await pauseUploadVideo();
  }

  @override
  Future<int> publishVideo() async {
    return await uploader.publishVideo(TXPublishParam(
      signature: widget.signature,
      videoPath: widget.filePath,
      fileName: widget.fileName,
      coverPath: _coverPath,
    ));
  }

  @override
  Future<int> resumeUploadVideo() async {
    return await uploader.resumeUploadVideo(TXPublishParam(
      signature: widget.signature,
      videoPath: widget.filePath,
      fileName: widget.fileName,
      coverPath: _coverPath,
    ));
  }

  Future<XFile?> getImage() async {
    return await _mediaPicker.pickImage(source: ImageSource.gallery);
  }
}

class _ImageItemState extends _IFileItemState {
  @override
  void initState() {
    super.initState();
    uploader.setMediaListener(this);
  }

  @override
  Future<void> pause() async {
    return await pauseUploadMedia();
  }

  @override
  Future<int> publish() async {
    return await publishMedia();
  }

  @override
  Future<int> resume() async {
    return await resumeUploadMedia();
  }

  @override
  Future<void> cancel() async {
    return await cancelUploadVideo();
  }
}

abstract class _IFileItemState extends State<FileItem>
    implements ITXVideoPublishListener, ITXMediaPublishListener {
  double currentProgress = 0;

  late String taskId;

  late TXUGCPublish uploader;

  _IFileItemState() {
    taskId = const Uuid().v4().replaceAll("-", "");
    uploader = TXUGCPublish(
      id: taskId,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
          ),
          Text(
            StringUtils.isNotEmpty(widget.filePath)
                ? widget.filePath.toString()
                : "",
            style: const TextStyle(color: Color(0xFF0175C2), fontSize: 20),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
          ),
          Slider(
            value: currentProgress,
            min: 0.0,
            max: 100.0,
            onChanged: (double value) {},
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                child: Text(
                  AppLocals.of(context).startUpload,
                  style: TextStyle(color: Color(0xFF0175C2), fontSize: 18),
                ),
                onTap: () async {
                  if (StringUtils.isEmpty(widget.filePath) ||
                      StringUtils.isEmpty(widget.fileName)) {
                    EasyLoading.showError(AppLocals.of(context).noFileSelected);
                    return;
                  }
                  var res = await publish();
                  String resResult = res.toString();
                  if (res == ErrorCode.TVC_ERR_INVALID_SIGNATURE) {
                    resResult = AppLocals.of(context).signatureIsNull;
                  } else if (res == ErrorCode.TVC_ERR_INVALID_VIDEOPATH) {
                    resResult = AppLocals.of(context).videoPathIsNull;
                  } else if (res == ErrorCode.TVC_ERR_FILE_NOT_EXIST) {
                    resResult = AppLocals.of(context).fileNotExist;
                  } else if(res == ErrorCode.TVC_ERR_ERR_UGC_PUBLISHING) {
                    resResult = AppLocals.of(context).hasFileUploading;
                  } else if (res == ErrorCode.TVC_ERR_UGC_INVALID_PARAME) {
                    resResult = AppLocals.of(context).uploadParamInvalid;
                  }
                  EasyLoading.showToast(resResult);
                },
              ),
              InkWell(
                child: Text(
                  AppLocals.of(context).cancelUpload,
                  style: TextStyle(color: Color(0xFF0175C2), fontSize: 18),
                ),
                onTap: () {
                  pause();
                },
              ),
              InkWell(
                child: Text(
                  AppLocals.of(context).resumeUpload,
                  style: TextStyle(color: Color(0xFF0175C2), fontSize: 18),
                ),
                onTap: () {
                  resume();
                },
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                child: Text(
                  AppLocals.of(context).getStatusInfo,
                  style: TextStyle(color: Color(0xFF0175C2), fontSize: 18),
                ),
                onTap: () async {
                  ReportInfo? info = await getStatusInfo();
                  if (info == null) {
                    EasyLoading.showError(AppLocals.of(context).infoNotObtained);
                    return;
                  }
                  EasyLoading.showToast(info.toString());
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<int> publish();

  Future<void> pause();

  Future<void> cancel();

  Future<int> resume();

  Future<ReportInfo?> getStatusInfo() async {
    return await uploader.getStatusInfo();
  }

  Future<int> publishVideo() async {
    return await uploader.publishVideo(TXPublishParam(
      signature: widget.signature,
      videoPath: widget.filePath,
      fileName: widget.fileName,
    ));
  }

  Future<int> publishMedia() async {
    return await uploader.publishMedia(TXMediaPublishParam(
      signature: widget.signature,
      mediaPath: widget.filePath,
      fileName: widget.fileName,
    ));
  }

  Future<void> pauseUploadVideo() async {
    return await uploader.pauseUploadVideo();
  }

  Future<int> resumeUploadVideo() async {
    return await uploader.resumeUploadVideo(TXPublishParam(
      signature: widget.signature,
      videoPath: widget.filePath,
      fileName: widget.fileName,
    ));
  }

  Future<void> cancelUploadVideo() async {
    return await uploader.cancelUploadVideo();
  }

  Future<void> pauseUploadMedia() async {
    return await uploader.pauseUploadMedia();
  }

  Future<int> resumeUploadMedia() async {
    return await uploader.resumeUploadMedia(TXMediaPublishParam(
      signature: widget.signature,
      mediaPath: widget.filePath,
      fileName: widget.fileName,
    ));
  }

  Future<void> cancelUploadMedia() async {
    return await uploader.cancelUploadMedia();
  }

  void clearItem() {
    cancel();
  }

  @override
  void onPublishComplete(TXPublishResult result) {
    EasyLoading.showToast(result.retCode?.toString() ?? "ERROR");
  }

  @override
  void onPublishProgress(int uploadBytes, int totalBytes) {
    double progress = (100 * uploadBytes / totalBytes);
    setState(() {
      currentProgress = progress;
    });
  }

  @override
  void onMediaPublishComplete(TXMediaPublishResult result) {
    EasyLoading.showToast(result.retCode?.toString() ?? "ERROR");
  }

  @override
  void onMediaPublishProgress(int uploadBytes, int totalBytes) {
    double progress = (100 * uploadBytes / totalBytes);
    setState(() {
      currentProgress = progress;
    });
  }
}
