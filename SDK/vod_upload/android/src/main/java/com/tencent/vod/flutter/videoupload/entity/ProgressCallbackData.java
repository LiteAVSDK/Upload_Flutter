package com.tencent.vod.flutter.videoupload.entity;

public class ProgressCallbackData {
    public String id;
    public int progress;
    public long uploadBytes;
    public long totalBytes;
    public boolean isComplete;
    public Object detail;
}
