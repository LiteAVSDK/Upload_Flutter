package com.tencent.vod.flutter.videoupload.entity;

import android.util.Log;
import com.tencent.vod.flutter.videoupload.util.JsonUtils;
import org.json.JSONObject;

public class PublishResult {

    private static final String TAG = "PublishResult";

    public int code;
    public String msg;
    public Object data;

    public static final int SUCCESS_CODE = 0;
    public static final int FAIL_CODE = 1;
    public static final String SUCCESS_MSG = "OK";
    public static final String FAIL_MSG = "ERROR";
    public static final String NULL_MSG = "NULL";

    public static PublishResult constructor(int code) {
        PublishResult template = new PublishResult();
        template.code = code;
        template.msg = NULL_MSG;
        return template;
    }

    public static PublishResult constructor(int code, String msg) {
        PublishResult template = new PublishResult();
        template.code = SUCCESS_CODE;
        template.msg = SUCCESS_MSG;
        return template;
    }

    public static PublishResult constructor(int code, String msg, Object data) {
        PublishResult template = new PublishResult();
        template.code = SUCCESS_CODE;
        template.msg = SUCCESS_MSG;
        template.data = data;
        return template;
    }

    public static PublishResult success(Object data) {
        PublishResult template = new PublishResult();
        template.code = SUCCESS_CODE;
        template.msg = SUCCESS_MSG;
        template.data = data;
        return template;
    }

    public static PublishResult success() {
        PublishResult template = new PublishResult();
        template.code = SUCCESS_CODE;
        template.msg = SUCCESS_MSG;
        return template;
    }

    public static PublishResult error() {
        PublishResult template = new PublishResult();
        template.code = FAIL_CODE;
        template.msg = FAIL_MSG;
        return template;
    }

    public String toJson() {
        try {
            JSONObject json = JsonUtils.toJson(this);
            return json.toString();
        } catch (Exception e) {
            Log.e(TAG, e.getMessage(), e);
        }
        return "{" + "code:" + code + "," + "msg:" + msg + "}";
    }
}