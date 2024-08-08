package com.tencent.vod.flutter.videoupload;

import android.app.Activity;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.NonNull;
import com.tencent.vod.flutter.videoupload.entity.ProgressCallbackData;
import com.tencent.vod.flutter.videoupload.entity.PublishResult;
import com.tencent.vod.flutter.videoupload.entity.TXUGCPublishCache;
import com.tencent.vod.flutter.videoupload.entity.TXUGCPublishConstants;
import com.tencent.vod.flutter.videoupload.impl.TVCLog;
import com.tencent.vod.flutter.videoupload.impl.TVCNetWorkStateReceiver;
import com.tencent.vod.flutter.videoupload.impl.TXUGCPublishOptCenter;
import com.tencent.vod.flutter.videoupload.impl.UploadResumeDefaultController;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class FTXUGCPublishPlugin implements FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private static final String TAG = "FTXUGCPublishPlugin";
    private static final String PUBLISH_METHOD_CHANNEL_PATH = "cloud.tencent.com/txvodplayer/videoUpload";
    private static final Map<String, TXUGCPublishCache> PUBLISH_CACHE = new ConcurrentHashMap<>();
    private FlutterPlugin.FlutterPluginBinding mBinding;
    private MethodChannel mMethodChannel;
    private Activity mActivity;
    private TVCNetWorkStateReceiver mNetWorkStateReceiver;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        mBinding = binding;
        mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), PUBLISH_METHOD_CHANNEL_PATH);
        mMethodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mBinding = null;
        mMethodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String id = call.argument("id");
        TXUGCPublishTypeDef.TXPublishParam videoArgs;
        TXUGCPublishTypeDef.TXMediaPublishParam mediaArgs;
        int code;
        TVCLog.d(TAG, String.format("Flutter TXUGCPublish onMethodCall : %s id : %s", call.method, id));
        switch (call.method) {
            case TXUGCPublishConstants.Apis.PUBLISH_VIDEO:
                videoArgs = parsePublishVideoArgs(call);
                code = publishVideo(id, videoArgs);
                result.success(PublishResult.constructor(code).toJson());
                return;
            case TXUGCPublishConstants.Apis.RESUME_UPLOAD_VIDEO:
                videoArgs = parsePublishVideoArgs(call);
                code = resumeUploadVideo(id, videoArgs);
                result.success(PublishResult.constructor(code).toJson());
                return;
            case TXUGCPublishConstants.Apis.PAUSE_UPLOAD_VIDEO:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                pauseUploadVideo(id);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.CANCEL_UPLOAD_VIDEO:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                cancelUploadVideo(id);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.PUBLISH_MEDIA:
                mediaArgs = parsePublishMediaArgs(call);
                code = publishMedia(id, mediaArgs);
                result.success(PublishResult.constructor(code).toJson());
                return;
            case TXUGCPublishConstants.Apis.PAUSE_UPLOAD_MEDIA:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                pauseUploadMedia(id);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.CANCEL_UPLOAD_MEDIA:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                cancelUploadMedia(id);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.RESUME_UPLOAD_MEDIA:
                mediaArgs = parsePublishMediaArgs(call);
                code = resumeUploadMedia(id, mediaArgs);
                result.success(PublishResult.constructor(code).toJson());
                return;
            case TXUGCPublishConstants.Apis.REMOVE_CACHE:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                removeCache(id);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.PREPARE_UPLOAD:
                String signature = call.argument("signature");
                if (TextUtils.isEmpty(signature)) {
                    result.error("-1", "signature is empty", "");
                    break;
                }
                prepareUpload(signature, result);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.SET_APPID:
                Integer appId = call.argument("appId");
                if (TextUtils.isEmpty(id) || appId == null) {
                    result.error("-1", "id or appId is empty", "");
                    break;
                }
                setAppId(id, appId);
                result.success(null);
                return;
            case TXUGCPublishConstants.Apis.GET_STATUS_INFO:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                JSONObject info = getStatusInfo(id);
                result.success(PublishResult.success(info).toJson());
                return;
            case TXUGCPublishConstants.Apis.SET_IS_DEBUG:
                if (TextUtils.isEmpty(id)) {
                    result.error("-1", "id is empty", "");
                    break;
                }
                Boolean isDebug = call.argument("isDebug");
                setIsDebug(id, isDebug);
                result.success(null);
                return;
            default:
                break;
        }
        PublishResult template = PublishResult.constructor(PublishResult.FAIL_CODE, "Method Not Found | Args Illegal");
        result.error(String.valueOf(template.code), template.msg, null);
    }

    private TXUGCPublishTypeDef.TXPublishParam parsePublishVideoArgs(MethodCall call) {
        return (TXUGCPublishTypeDef.TXPublishParam) setArgs(TXUGCPublishTypeDef.TXPublishParam.class, (Map<String, Object>) call.arguments);
    }

    private TXUGCPublishTypeDef.TXMediaPublishParam parsePublishMediaArgs(MethodCall call) {
        return (TXUGCPublishTypeDef.TXMediaPublishParam) setArgs(TXUGCPublishTypeDef.TXMediaPublishParam.class, (Map<String, Object>) call.arguments);
    }

    @Deprecated
    private void setArgs(Object target, MethodCall call) {
        Field[] fields = target.getClass().getDeclaredFields();
        for (Field field : fields) {
            field.setAccessible(true);
            Object val = call.argument(field.getName());
            if (val == null) continue;
            try {
                field.set(target, val);
            } catch (Exception e) {
                TVCLog.e(TAG, e.getMessage(), e);
            }
        }
    }

    private Object setArgs(Class<?> clazz, Map<String, Object> args) {
        Object target;
        try {
            target = clazz.newInstance();
        } catch (Exception e) {
            TVCLog.e(TAG, e.getMessage(), e);
            return null;
        }
        Field[] fields = clazz.getDeclaredFields();
        for (Field field : fields) {
            field.setAccessible(true);
            Object val = args.get(field.getName());
            if (val == null) continue;
            if (val instanceof Map) {
                try {
                    field.set(target, setArgs(field.getType(), (Map<String, Object>) val));
                } catch (Exception e) {
                    TVCLog.e(TAG, e.getMessage(), e);
                }
            } else {
                try {
                    field.set(target, val);
                } catch (Exception e) {
                    TVCLog.e(TAG, e.getMessage(), e);
                }
            }
        }
        return target;
    }

    private int publishVideo(String id, TXUGCPublishTypeDef.TXPublishParam args) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache == null) {
            cache = initCache(id, (TXUGCPublishTypeDef.ITXVideoPublishListener) new TXPublishListenerImpl(id, mMethodChannel));
        }
        TXUGCPublishTypeDef.TXPublishParam param = new TXUGCPublishTypeDef.TXPublishParam();
        param.signature = args.signature;
        param.videoPath = args.videoPath;
        param.fileName = args.fileName;
        param.enableHttps = args.enableHttps;
        param.sliceSize = args.sliceSize;
        param.enablePreparePublish = args.enablePreparePublish;
        param.concurrentCount = args.concurrentCount;
        param.coverPath = args.coverPath;
        param.enableResume = args.enableResume;
        if (args.isDefaultResumeController) {
            param.uploadResumeController = new UploadResumeDefaultController(mActivity);
        } else {
            param.uploadResumeController = new UploadResumeFlutterController(mMethodChannel, mActivity);
        }
        return cache.publisher.publishVideo(param);
    }

    private void pauseUploadVideo(String id) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache != null) {
            cache.publisher.canclePublish();
        }
    }

    private void cancelUploadVideo(String id) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache != null) {
            cache.publisher.canclePublish();
        }
    }

    private void pauseUploadMedia(String id) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache != null) {
            cache.publisher.canclePublish();
        }
    }

    private void cancelUploadMedia(String id) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache != null) {
            cache.publisher.canclePublish();
        }
    }

    private int resumeUploadVideo(String id, TXUGCPublishTypeDef.TXPublishParam args) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache != null) {
            TXUGCPublishTypeDef.TXPublishParam param = new TXUGCPublishTypeDef.TXPublishParam();
            // signature计算规则可参考 https://www.qcloud.com/document/product/266/9221
            param.signature = args.signature;
            param.videoPath = args.videoPath;
            param.fileName = args.fileName;
            param.enableHttps = args.enableHttps;
            param.sliceSize = args.sliceSize;
            param.enablePreparePublish = args.enablePreparePublish;
            param.concurrentCount = args.concurrentCount;
            param.coverPath = args.coverPath;
            param.enableResume = args.enableResume;
            if (args.isDefaultResumeController) {
                param.uploadResumeController = new UploadResumeDefaultController(mActivity);
            } else {
                param.uploadResumeController = new UploadResumeFlutterController(mMethodChannel, mActivity);
            }
            return cache.publisher.publishVideo(param);
        }
        return 1;
    }

    private int resumeUploadMedia(String id, TXUGCPublishTypeDef.TXMediaPublishParam args) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache != null) {
            TXUGCPublishTypeDef.TXMediaPublishParam param = new TXUGCPublishTypeDef.TXMediaPublishParam();
            // signature计算规则可参考 https://www.qcloud.com/document/product/266/9221
            param.signature = args.signature;
            param.mediaPath = args.mediaPath;
            param.fileName = args.fileName;
            param.enableHttps = args.enableHttps;
            param.sliceSize = args.sliceSize;
            param.enablePreparePublish = args.enablePreparePublish;
            param.concurrentCount = args.concurrentCount;
            param.enableResume = args.enableResume;
            if (args.isDefaultResumeController) {
                param.uploadResumeController = new UploadResumeDefaultController(mActivity);
            } else {
                param.uploadResumeController = new UploadResumeFlutterController(mMethodChannel, mActivity);
            }
            return cache.publisher.publishMedia(param);
        }
        return 1;
    }

    private int publishMedia(String id, TXUGCPublishTypeDef.TXMediaPublishParam args) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(id);
        if (cache == null) {
            cache = initCache(id, (TXUGCPublishTypeDef.ITXMediaPublishListener) new TXPublishListenerImpl(id, mMethodChannel));
        }
        TXUGCPublishTypeDef.TXMediaPublishParam param = new TXUGCPublishTypeDef.TXMediaPublishParam();
        param.signature = args.signature;
        param.mediaPath = args.mediaPath;
        param.fileName = args.fileName;
        param.enableHttps = args.enableHttps;
        param.sliceSize = args.sliceSize;
        param.enablePreparePublish = args.enablePreparePublish;
        param.concurrentCount = args.concurrentCount;
        param.enableResume = args.enableResume;
        if (args.isDefaultResumeController) {
            param.uploadResumeController = new UploadResumeDefaultController(mActivity);
        } else {
            param.uploadResumeController = new UploadResumeFlutterController(mMethodChannel, mActivity);
        }
        return cache.publisher.publishMedia(param);
    }

    private void prepareUpload(String signature, MethodChannel.Result result) {
        TXUGCPublishOptCenter.getInstance().prepareUpload(mActivity, signature, () -> {
            PublishResult res = PublishResult.constructor(PublishResult.SUCCESS_CODE, PublishResult.SUCCESS_MSG);
            TVCLog.d(TAG, String.format("prepareUpload result : %s", result.toString()));
            result.success(res.toJson());
        });
    }

    private void setAppId(String taskId, int appId) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(taskId);
        if (cache != null) {
            cache.publisher.setAppId(appId);
        }
    }

    private JSONObject getStatusInfo(String taskId) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(taskId);
        if (cache != null) {
            JSONObject jsonObject = new JSONObject();
            Bundle b = cache.publisher.getStatusInfo();
            try {
                jsonObject.put("reqType", b.getString("reqType"));
                jsonObject.put("errCode", b.getString("errCode"));
                jsonObject.put("errMsg", b.getString("errMsg"));
                jsonObject.put("reqTime", b.getString("reqTime"));
                jsonObject.put("reqTimeCost", b.getString("reqTimeCost"));
                jsonObject.put("fileSize", b.getString("fileSize"));
                jsonObject.put("fileType", b.getString("fileType"));
                jsonObject.put("fileName", b.getString("fileName"));
                jsonObject.put("fileId", b.getString("fileId"));
                jsonObject.put("appId", b.getString("appId"));
                jsonObject.put("reqServerIp", b.getString("reqServerIp"));
                jsonObject.put("reportId", b.getString("reportId"));
                jsonObject.put("cosVideoPath", b.getString("cosVideoPath"));
                jsonObject.put("reqKey", b.getString("reqKey"));
                jsonObject.put("vodSessionKey", b.getString("vodSessionKey"));

                jsonObject.put("cosRegion", b.getString("cosRegion"));
                jsonObject.put("vodErrCode", b.getInt("vodErrCode"));
                jsonObject.put("cosErrCode", b.getString("cosErrCode"));
                jsonObject.put("useHttpDNS", b.getInt("useHttpDNS"));
                jsonObject.put("useCosAcc", b.getInt("useCosAcc"));
                jsonObject.put("tcpConnTimeCost", b.getLong("tcpConnTimeCost"));
                jsonObject.put("tcpConnTimeCost", b.getLong("recvRespTimeCost"));
            } catch (Exception e) {
                TVCLog.e(TAG, e.getMessage(), e);
            }
            return jsonObject;
        }
        return null;
    }

    private void removeCache(String id) {
        PUBLISH_CACHE.remove(id);
    }

    private void setIsDebug(String taskId, boolean isDebug) {
        TXUGCPublishCache cache = PUBLISH_CACHE.get(taskId);
        if (cache != null) {
            cache.publisher.setIsDebug(isDebug);
        }
    }

    private void registerNetReceiver() {
        if (null == mNetWorkStateReceiver) {
            mNetWorkStateReceiver = new TVCNetWorkStateReceiver();
            IntentFilter intentFilter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
            mActivity.registerReceiver(mNetWorkStateReceiver, intentFilter);
        }
    }

    private void unRegisterNetReceiver() {
        if (null != mNetWorkStateReceiver) {
            mActivity.unregisterReceiver(mNetWorkStateReceiver);
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull @NotNull ActivityPluginBinding binding) {
        TVCLog.i(TAG, "FTXUGCPublishPlugin Init");
        mActivity = binding.getActivity();
        registerNetReceiver();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        unRegisterNetReceiver();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull @NotNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
    }

    private TXUGCPublishCache initCache(String id, TXUGCPublishTypeDef.ITXVideoPublishListener listener) {
        TXUGCPublishCache cache = initCache(id);
        cache.publisher.setListener(listener);
        return cache;
    }

    private TXUGCPublishCache initCache(String id, TXUGCPublishTypeDef.ITXMediaPublishListener listener) {
        TXUGCPublishCache cache = initCache(id);
        cache.publisher.setListener(listener);
        return cache;
    }

    private TXUGCPublishCache initCache(String id) {
        TXUGCPublishCache cache = new TXUGCPublishCache();
        PUBLISH_CACHE.put(id, cache);
        cache.publisher = new TXUGCPublish(mBinding.getApplicationContext(), "independence_android");
        return cache;
    }

    static class TXPublishListenerImpl implements TXUGCPublishTypeDef.ITXVideoPublishListener, TXUGCPublishTypeDef.ITXMediaPublishListener {
        private final String id;
        private final MethodChannel apiChannel;

        public TXPublishListenerImpl(String id, MethodChannel apiChannel) {
            this.id = id;
            this.apiChannel = apiChannel;
        }

        void onProgress(String method, long uploadBytes, long totalBytes) {
            int progress = (int) (100 * uploadBytes / totalBytes);
            ProgressCallbackData data = new ProgressCallbackData();
            data.id = id;
            data.progress = progress;
            data.isComplete = false;
            data.uploadBytes = uploadBytes;
            data.totalBytes = totalBytes;
            PublishResult template = PublishResult.success(data);
            Map<String, String> args = new HashMap<>();
            args.put("id", id);
            args.put("callback", template.toJson());
            apiChannel.invokeMethod(method, args);
        }

        void onComplete(String method, Object result) {
            ProgressCallbackData data = new ProgressCallbackData();
            data.id = id;
            data.progress = 100;
            data.isComplete = true;
            data.uploadBytes = 0;
            data.totalBytes = 0;
            data.detail = result;
            PublishResult template = PublishResult.success(data);
            Map<String, String> args = new HashMap<>();
            args.put("id", id);
            args.put("callback", template.toJson());
            apiChannel.invokeMethod(method, args);
        }

        @Override
        public void onPublishProgress(long uploadBytes, long totalBytes) {
            onProgress(TXUGCPublishConstants.Apis.ON_PUBLISH_PROGRESS, uploadBytes, totalBytes);
        }

        @Override
        public void onPublishComplete(TXUGCPublishTypeDef.TXPublishResult result) {
            onComplete(TXUGCPublishConstants.Apis.ON_PUBLISH_COMPLETE, result);
        }

        @Override
        public void onMediaPublishProgress(long uploadBytes, long totalBytes) {
            onProgress(TXUGCPublishConstants.Apis.ON_MEDIA_PUBLISH_PROGRESS, uploadBytes, totalBytes);
        }

        @Override
        public void onMediaPublishComplete(TXUGCPublishTypeDef.TXMediaPublishResult mediaResult) {
            onComplete(TXUGCPublishConstants.Apis.ON_MEDIA_PUBLISH_COMPLETE, mediaResult);
        }
    }
}
