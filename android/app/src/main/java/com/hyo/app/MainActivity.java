package com.hyo.app;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;

public class MainActivity extends Activity implements SurfaceHolder.Callback {
    private static final String TAG = "HyoMainActivity";

    static {
        try {
            System.loadLibrary("hyo");
            Log.i(TAG, "Successfully loaded libhyo.so");
        } catch (UnsatisfiedLinkError e) {
            Log.e(TAG, "Failed to load libhyo.so: " + e.getMessage());
        }
    }

    private SurfaceView surfaceView;
    private EditText hiddenInput;
    private boolean isUpdatingText = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        );

        FrameLayout rootLayout = new FrameLayout(this);

        surfaceView = new SurfaceView(this);
        surfaceView.getHolder().addCallback(this);
        rootLayout.addView(surfaceView, new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        // Invisible native input for soft keyboard integration
        hiddenInput = new EditText(this);
        hiddenInput.setLayoutParams(new FrameLayout.LayoutParams(1, 1));
        hiddenInput.setAlpha(0.0f);
        hiddenInput.setSingleLine(true);
        hiddenInput.setImeOptions(EditorInfo.IME_ACTION_DONE);
        hiddenInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if (!isUpdatingText) {
                    nativeOnTextInput(s.toString());
                }
            }
        });
        hiddenInput.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                hideSoftKeyboard();
                nativeDismissKeyboard();
                return true;
            }
            return false;
        });
        rootLayout.addView(hiddenInput);

        setContentView(rootLayout);

        surfaceView.setOnTouchListener((v, event) -> {
            int action = -1;
            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN:
                    action = 0;
                    break;
                case MotionEvent.ACTION_UP:
                    action = 1;
                    break;
                case MotionEvent.ACTION_MOVE:
                    action = 2;
                    break;
            }
            if (action >= 0) {
                nativeOnTouchEvent(action, event.getX(), event.getY());
            }
            return true;
        });

        float density = getResources().getDisplayMetrics().density;
        Log.i(TAG, "Screen density: " + density);
        nativeInit(getAssets(), density);
    }

    public void showSoftKeyboard(final String initialText) {
        runOnUiThread(() -> {
            isUpdatingText = true;
            hiddenInput.setText(initialText);
            if (initialText != null) {
                hiddenInput.setSelection(initialText.length());
            }
            isUpdatingText = false;
            hiddenInput.requestFocus();
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm != null) {
                imm.showSoftInput(hiddenInput, InputMethodManager.SHOW_IMPLICIT);
            }
        });
    }

    public void hideSoftKeyboard() {
        runOnUiThread(() -> {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm != null) {
                imm.hideSoftInputFromWindow(hiddenInput.getWindowToken(), 0);
            }
            hiddenInput.clearFocus();
        });
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.i(TAG, "surfaceCreated");
        nativeSurfaceCreated(holder.getSurface());
        if (surfaceView.getWidth() > 0 && surfaceView.getHeight() > 0) {
            nativeSurfaceChanged(surfaceView.getWidth(), surfaceView.getHeight());
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Log.i(TAG, "surfaceChanged: " + width + "x" + height);
        nativeSurfaceChanged(width, height);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.i(TAG, "surfaceDestroyed");
        nativeSurfaceDestroyed();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        nativeOnTouchEvent(event.getActionMasked(), event.getX(), event.getY());
        return true;
    }

    // Native JNI functions implemented in hyo-core
    private native void nativeInit(Object assetManager, float density);
    private native void nativeSurfaceCreated(Surface surface);
    private native void nativeSurfaceChanged(int width, int height);
    private native void nativeSurfaceDestroyed();
    private native void nativeOnTouchEvent(int action, float x, float y);
    private native void nativeOnTextInput(String text);
    private native void nativeDismissKeyboard();
}
