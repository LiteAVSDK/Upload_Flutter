package com.tencent.vod.flutter.videoupload.util;

import android.util.Log;
import io.flutter.plugin.common.MethodCall;

import java.lang.reflect.Field;

public class BeanUtils {

    private static final String TAG = "BeanUtils";

    public static void setProperty(Object target, MethodCall call) {
        if (target == null || call == null) return;
        Class<?> clazz = target.getClass();
        Field[] fields = clazz.getDeclaredFields();
        for (Field field : fields) {
            field.setAccessible(true);
            Object val = call.argument(field.getName());
            if (val == null) continue;
            try {
                field.set(target, val);
            } catch (Exception e) {
                Log.e(TAG, e.getMessage(), e);
            }
        }
    }
}
