package com.hyo.app;

/**
 * Interface for native Android plugins exposed to Lua via `hyo.bridge.call(module, method, argsJson, cb)`.
 */
public interface HyoPlugin {
    String getName();
    String handleCall(String method, String argsJson) throws Exception;
}

