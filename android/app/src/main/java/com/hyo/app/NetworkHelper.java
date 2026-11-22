package com.hyo.app;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

public class NetworkHelper {

    private static final ExecutorService executor = Executors.newCachedThreadPool();

    public static String[] httpGet(String urlStr, int timeoutMs) {
        Future<String[]> future = executor.submit(new Callable<String[]>() {
            @Override
            public String[] call() {
                String[] result = new String[]{"0", "", ""};
                HttpURLConnection conn = null;
                try {
                    URL url = new URL(urlStr);
                    conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");
                    conn.setConnectTimeout(timeoutMs);
                    conn.setReadTimeout(timeoutMs);
                    conn.setRequestProperty("User-Agent", "HyoFramework/0.1.0");

                    int code = conn.getResponseCode();
                    result[0] = String.valueOf(code);

                    InputStream is = (code >= 200 && code < 400) ? conn.getInputStream() : conn.getErrorStream();
                    if (is != null) {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                        StringBuilder sb = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            sb.append(line).append("\n");
                        }
                        reader.close();
                        result[1] = sb.toString();
                    }
                } catch (Exception e) {
                    result[2] = e.getMessage() != null ? e.getMessage() : e.toString();
                } finally {
                    if (conn != null) {
                        conn.disconnect();
                    }
                }
                return result;
            }
        });

        try {
            return future.get(timeoutMs + 2000, TimeUnit.MILLISECONDS);
        } catch (Exception e) {
            return new String[]{"0", "", "Network error: " + (e.getMessage() != null ? e.getMessage() : e.toString())};
        }
    }

    public static String[] httpPost(String urlStr, String body, String contentType, int timeoutMs) {
        Future<String[]> future = executor.submit(new Callable<String[]>() {
            @Override
            public String[] call() {
                String[] result = new String[]{"0", "", ""};
                HttpURLConnection conn = null;
                try {
                    URL url = new URL(urlStr);
                    conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("POST");
                    conn.setConnectTimeout(timeoutMs);
                    conn.setReadTimeout(timeoutMs);
                    conn.setDoOutput(true);
                    conn.setRequestProperty("Content-Type", contentType);
                    conn.setRequestProperty("User-Agent", "HyoFramework/0.1.0");

                    byte[] out = body.getBytes(StandardCharsets.UTF_8);
                    conn.setFixedLengthStreamingMode(out.length);
                    try (OutputStream os = conn.getOutputStream()) {
                        os.write(out);
                    }

                    int code = conn.getResponseCode();
                    result[0] = String.valueOf(code);

                    InputStream is = (code >= 200 && code < 400) ? conn.getInputStream() : conn.getErrorStream();
                    if (is != null) {
                        BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                        StringBuilder sb = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            sb.append(line).append("\n");
                        }
                        reader.close();
                        result[1] = sb.toString();
                    }
                } catch (Exception e) {
                    result[2] = e.getMessage() != null ? e.getMessage() : e.toString();
                } finally {
                    if (conn != null) {
                        conn.disconnect();
                    }
                }
                return result;
            }
        });

        try {
            return future.get(timeoutMs + 2000, TimeUnit.MILLISECONDS);
        } catch (Exception e) {
            return new String[]{"0", "", "Network error: " + (e.getMessage() != null ? e.getMessage() : e.toString())};
        }
    }
}
