package com.tencent.vod.flutter.videoupload.entity;

public class TXUGCPublishConstants {

    public interface Apis {
        String PUBLISH_VIDEO = "publishVideo";
        String PAUSE_UPLOAD_VIDEO = "pauseUploadVideo";
        String RESUME_UPLOAD_VIDEO = "resumeUploadVideo";
        String CANCEL_UPLOAD_VIDEO = "cancelUploadVideo";
        String PUBLISH_MEDIA = "publishMedia";
        String PAUSE_UPLOAD_MEDIA = "pauseUploadMedia";
        String RESUME_UPLOAD_MEDIA = "resumeUploadMedia";
        String CANCEL_UPLOAD_MEDIA = "cancelUploadMedia";
        String REMOVE_CACHE = "removeCache";
        String PREPARE_UPLOAD = "prepareUpload";
        String SET_APPID = "setAppId";
        String GET_STATUS_INFO = "getStatusInfo";
        String ON_PUBLISH_PROGRESS = "onPublishProgress";
        String ON_PUBLISH_COMPLETE = "onPublishComplete";
        String ON_MEDIA_PUBLISH_PROGRESS = "onMediaPublishProgress";
        String ON_MEDIA_PUBLISH_COMPLETE = "onMediaPublishComplete";
        String SET_IS_DEBUG = "setIsDebug";
    }
}
