package com.tencent.vod.flutter.videoupload;

import android.app.Activity;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.tencent.vod.flutter.videoupload.impl.IUploadResumeController;
import com.tencent.vod.flutter.videoupload.impl.ResumeCacheData;
import com.tencent.vod.flutter.videoupload.impl.TVCUploadInfo;
import com.tencent.vod.flutter.videoupload.util.JsonUtils;
import com.tencent.vod.flutter.videoupload.util.Sync;
import io.flutter.plugin.common.MethodChannel;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class UploadResumeFlutterController implements IUploadResumeController {

    private final MethodChannel mMethodChannel;

    private final Activity mActivity;

    private static final String TAG = "ResumeFlutterController";

    public UploadResumeFlutterController(MethodChannel methodChannel, Activity activity) {
        mMethodChannel = methodChannel;
        mActivity = activity;
    }

    @Override
    public ResumeCacheData getResumeData(String filePath) {
        Map<String, Object> args = new HashMap<>();
        args.put("filePath", filePath);
        Sync sync = new Sync();
        mActivity.runOnUiThread(() -> mMethodChannel.invokeMethod("getResumeData", args, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
                Map<String, String> map = (Map<String, String>) result;
                String data = map.get("data");
                try {
                    ResumeCacheData resumeCacheData = new ResumeCacheData();
                    JSONObject json = new JSONObject(data);
                    resumeCacheData.setUploadId(json.optString("uploadId"));
                    resumeCacheData.setVodSessionKey(json.optString("vodSessionKey"));
                    resumeCacheData.setCoverFileLastModTime(json.optLong("coverFileLastModTime"));
                    resumeCacheData.setFileLastModTime(json.optLong("fileLastModTime"));
                    sync.setData(resumeCacheData);
                    sync.done();
                } catch (Exception e) {
                    Log.e(TAG, e.getMessage(), e);
                }
            }

            @Override
            public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                sync.done();
            }

            @Override
            public void notImplemented() {
                sync.done();
            }
        }));
        sync.await();
        return sync.getData();
    }

    @Override
    public boolean isResumeUploadVideo(String uploadId, TVCUploadInfo uploadInfo, String vodSessionKey, long fileLastModTime, long coverFileLastModTime) {
        Map<String, Object> args = new HashMap<>();
        try {
            args.put("vodSessionKey", vodSessionKey);
            args.put("uploadId", uploadId);
            args.put("uploadInfo", JsonUtils.toJson(uploadInfo).toString());
            args.put("fileLastModTime", fileLastModTime);
            args.put("coverFileLastModTime", coverFileLastModTime);
        } catch (Exception e) {
            Log.e(TAG, e.getMessage(), e);
        }
        if (args.isEmpty()) return false;
        Sync sync = new Sync();
        mActivity.runOnUiThread(() -> mMethodChannel.invokeMethod("isResumeUploadVideo", args, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
                Map<String, String> map = (Map<String, String>) result;
                String data = map.get("data");
                try {
                    JSONObject json = new JSONObject(data);
                    boolean isResumeUploadVideo = json.optBoolean("isResumeUploadVideo");
                    sync.setData(isResumeUploadVideo);
                    sync.done();
                } catch (Exception e) {
                    Log.e(TAG, e.getMessage(), e);
                }
            }

            @Override
            public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                sync.done();
            }

            @Override
            public void notImplemented() {
                sync.done();
            }
        }));
        sync.await();
        return sync.getData();
    }

    @Override
    public void clearLocalCache() {
        mActivity.runOnUiThread(() -> mMethodChannel.invokeMethod("clearLocalCache", new HashMap<>()));
    }

    @Override
    public void saveSession(String filePath, String vodSessionKey, String uploadId, TVCUploadInfo uploadInfo) {
        Map<String, Object> args = new HashMap<>();
        try {
            args.put("filePath", filePath);
            args.put("vodSessionKey", vodSessionKey);
            args.put("uploadId", uploadId);
            args.put("uploadInfo", JsonUtils.toJson(uploadInfo).toString());
        } catch (Exception e) {
            Log.e(TAG, e.getMessage(), e);
        }
        if (args.isEmpty()) return;
        mActivity.runOnUiThread(() -> mMethodChannel.invokeMethod("saveSession", args));
    }
}
