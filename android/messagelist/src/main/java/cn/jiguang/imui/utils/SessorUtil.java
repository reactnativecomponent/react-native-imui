package cn.jiguang.imui.utils;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioManager;

import com.dowin.imageviewer.FrescUtil;

import static android.content.Context.SENSOR_SERVICE;

/**
 * Created by dowin on 2017/8/23.
 */

public class SessorUtil implements SensorEventListener {
    private SensorManager sensorManager;
    private Sensor sensor;
    private boolean hasRegister;
    private boolean mIsEarPhoneOn;
    private Context mContext;
    private static SessorUtil instance = null;

    public static SessorUtil getInstance(Context context) {
        if (instance == null) {
            synchronized (SessorUtil.class) {
                if (instance == null) {
                    instance = new SessorUtil(context.getApplicationContext());
                }
            }
        }
        return instance;
    }

    private SessorUtil(Context context) {
        this.mContext = context;
    }

    public float getMaximumRange() {
        return sensor == null ? 0 : sensor.getMaximumRange();
    }

    public void register(boolean register) {

        if (hasRegister && register) {
            return;
        }

        if (sensorManager == null) {
            sensorManager = (SensorManager) mContext.getApplicationContext().getSystemService(SENSOR_SERVICE);
            sensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
        }
        if (register) {
            sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL);
        } else if (hasRegister && !register) {
            sensorManager.unregisterListener(this, sensor);
        }
        hasRegister = register;

        FrescUtil.init(mContext);
    }

    public boolean isEarPhoneOn() {
        return mIsEarPhoneOn;
    }

    public void setAudioPlayByEarPhone(int state) {
        AudioManager audioManager = (AudioManager) mContext
                .getSystemService(Context.AUDIO_SERVICE);
        int currVolume = audioManager.getStreamVolume(AudioManager.STREAM_VOICE_CALL);
        audioManager.setMode(AudioManager.MODE_IN_CALL);
        if (state == 0) {
            mIsEarPhoneOn = false;//AudioManager.STREAM_MUSIC
            audioManager.setSpeakerphoneOn(true);
            audioManager.setStreamVolume(AudioManager.STREAM_VOICE_CALL,
                    audioManager.getStreamMaxVolume(AudioManager.STREAM_VOICE_CALL),
                    AudioManager.STREAM_VOICE_CALL);
        } else {
            mIsEarPhoneOn = true;//AudioManager.STREAM_VOICE_CALL
            audioManager.setSpeakerphoneOn(false);
            audioManager.setStreamVolume(AudioManager.STREAM_VOICE_CALL, currVolume,
                    AudioManager.STREAM_VOICE_CALL);
        }
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        float value = event.values[0];

        if (value == getMaximumRange()) {
            setAudioPlayByEarPhone(0);
        } else {
            setAudioPlayByEarPhone(1);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }
}
