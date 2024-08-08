package com.tencent.vod.flutter.videoupload.util;

import android.util.Log;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

public class Sync {

    private static final String TAG = "Sync";

    private final CountDownLatch latch = new CountDownLatch(1);

    private volatile Object data;

    public void done() {
        latch.countDown();
    }

    public void setData(Object data) {
        this.data = data;
    }

    public <T> T getData() {
        return (T) data;
    }

    public void await() {
        try {
            latch.await();
        } catch (Exception e) {
            Log.e(TAG, e.getMessage(), e);
        }
    }

    public void await(long timeout, TimeUnit timeUnit) {
        try {
            boolean isTimeout = latch.await(timeout, timeUnit);
            if (!isTimeout) {
                Log.w(TAG, "sync timeout");
            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage(), e);
        }
    }
}
