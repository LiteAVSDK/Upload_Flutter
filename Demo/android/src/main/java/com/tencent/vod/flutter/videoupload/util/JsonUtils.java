package com.tencent.vod.flutter.videoupload.util;

import android.text.TextUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Collection;

public class JsonUtils {

    @Target(ElementType.FIELD)
    @Retention(RetentionPolicy.RUNTIME)
    public @interface JsonConvert {
        boolean ignore() default false;

        String name() default "";
    }

    public static JSONObject toJson(Object obj) throws Exception {
        JSONObject json = new JSONObject();
        Class<?> clazz = obj.getClass();
        for (Field field : clazz.getDeclaredFields()) {
            field.setAccessible(true);
            if (Modifier.isStatic(field.getModifiers())) continue;
            String name;
            JsonConvert anno = field.getAnnotation(JsonConvert.class);
            if (anno != null) {
                if (anno.ignore()) continue;
                if (!TextUtils.isEmpty(anno.name())) {
                    name = anno.name();
                } else {
                    name = field.getName();
                }
            } else {
                name = field.getName();
            }
            Object value = field.get(obj);
            if (value == null) {
                json.put(name, JSONObject.NULL);
            } else if (value instanceof Character || value instanceof String) {
                json.put(name, value.toString());
            } else if (value.getClass().isPrimitive()
                    || value instanceof Number
                    || value instanceof Boolean) {
                json.put(name, value);
            } else if (value instanceof Collection) {
                json.put(name, toJsonArray((Collection<?>) value));
            } else if (value.getClass().isArray()) {
                json.put(name, toJsonArray(Arrays.asList((Object[]) value)));
            } else if (value.getClass() == JSONObject.class) {
                json.put(name, value);
            } else {
                json.put(name, toJson(value));
            }
        }
        return json;
    }

    private static JSONArray toJsonArray(Collection<?> collection) throws Exception {
        JSONArray jsonArray = new JSONArray();
        for (Object obj : collection) {
            if (obj == null) {
                jsonArray.put(JSONObject.NULL);
            } else if (obj instanceof Character || obj instanceof String) {
                jsonArray.put(obj.toString());
            } else if (obj.getClass().isPrimitive()
                    || obj instanceof Number
                    || obj instanceof Boolean) {
                jsonArray.put(obj);
            } else if (obj instanceof Collection) {
                jsonArray.put(toJsonArray((Collection<?>) obj));
            } else if (obj.getClass().isArray()) {
                jsonArray.put(toJsonArray(Arrays.asList((Object[]) obj)));
            } else {
                jsonArray.put(toJson(obj));
            }
        }
        return jsonArray;
    }
}
