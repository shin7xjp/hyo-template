package com.hyo.app;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import org.json.JSONObject;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Central registry for Android native plugins.
 * Packages can register custom HyoPlugin implementations at startup.
 */
public class BridgeRegistry {
    private static final String TAG = "HyoBridge";
    private static final Map<String, HyoPlugin> plugins = new ConcurrentHashMap<>();

    public static void register(HyoPlugin plugin) {
        if (plugin != null && plugin.getName() != null) {
            plugins.put(plugin.getName(), plugin);
            Log.i(TAG, "Registered native plugin: " + plugin.getName());
        }
    }

    public static boolean hasPlugin(String name) {
        return name != null && plugins.containsKey(name);
    }

    /**
     * Called from C++ JNI: returns [resultJsonOrNull, errorStringOrNull].
     */
    public static String[] dispatch(String module, String method, String argsJson) {
        HyoPlugin plugin = plugins.get(module);
        if (plugin == null) {
            return new String[]{null, "Plugin '" + module + "' is not registered"};
        }
        try {
            String res = plugin.handleCall(method, argsJson != null ? argsJson : "{}");
            return new String[]{res != null ? res : "{}", null};
        } catch (Throwable t) {
            return new String[]{null, t.getMessage() != null ? t.getMessage() : t.toString()};
        }
    }

    public static void initDefaults(final Activity activity) {
        // Built-in device info plugin
        register(new HyoPlugin() {
            @Override
            public String getName() { return "device"; }

            @Override
            public String handleCall(String method, String argsJson) throws Exception {
                if ("getInfo".equals(method)) {
                    JSONObject obj = new JSONObject();
                    obj.put("manufacturer", Build.MANUFACTURER);
                    obj.put("model", Build.MODEL);
                    obj.put("sdkInt", Build.VERSION.SDK_INT);
                    obj.put("release", Build.VERSION.RELEASE);
                    return obj.toString();
                }
                throw new IllegalArgumentException("Unknown method: " + method);
            }
        });

        // Built-in clipboard plugin
        register(new HyoPlugin() {
            @Override
            public String getName() { return "clipboard"; }

            @Override
            public String handleCall(String method, String argsJson) throws Exception {
                ClipboardManager cm = (ClipboardManager) activity.getSystemService(Context.CLIPBOARD_SERVICE);
                if ("setText".equals(method)) {
                    JSONObject args = new JSONObject(argsJson);
                    String text = args.optString("text", "");
                    activity.runOnUiThread(() -> {
                        if (cm != null) {
                            cm.setPrimaryClip(ClipData.newPlainText("hyo", text));
                        }
                    });
                    return "{\"ok\":true}";
                } else if ("getText".equals(method)) {
                    String text = "";
                    if (cm != null && cm.hasPrimaryClip() && cm.getPrimaryClip() != null && cm.getPrimaryClip().getItemCount() > 0) {
                        CharSequence cs = cm.getPrimaryClip().getItemAt(0).coerceToText(activity);
                        if (cs != null) text = cs.toString();
                    }
                    return new JSONObject().put("text", text).toString();
                }
                throw new IllegalArgumentException("Unknown method: " + method);
            }
        });

        // Built-in share sheet plugin
        register(new HyoPlugin() {
            @Override
            public String getName() { return "share"; }

            @Override
            public String handleCall(String method, String argsJson) throws Exception {
                if ("text".equals(method)) {
                    JSONObject args = new JSONObject(argsJson);
                    String text = args.optString("text", "");
                    String title = args.optString("title", "Share");
                    activity.runOnUiThread(() -> {
                        Intent sendIntent = new Intent(Intent.ACTION_SEND);
                        sendIntent.putExtra(Intent.EXTRA_TEXT, text);
                        sendIntent.setType("text/plain");
                        activity.startActivity(Intent.createChooser(sendIntent, title));
                    });
                    return "{\"ok\":true}";
                }
                throw new IllegalArgumentException("Unknown method: " + method);
            }
        });
    }
}

