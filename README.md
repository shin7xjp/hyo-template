# Hyo Application Template

This is the official starter application template for the **Hyo** mobile application framework.

## Project Structure

```
.
├── hyo.json         # Project configuration, dependencies & metadata (JSON)
├── main.lua         # Primary application entry point (Lua 5.5.1)
├── assets/          # Static assets (fonts, images)
├── android/         # Android native host project (NDK + Gradle)
└── README.md
```

## Configuration (`hyo.json`)

All configuration is specified in JSON:

| Field | Type | Description |
|---|---|---|
| `name` | string | Application identifier (e.g. `myapp`) |
| `package` | string | Android package / application ID (e.g. `com.example.myapp`) |
| `version` | string | Semantic versioning |
| `entrypoint` | string | Script loaded at start (default: `main.lua`) |
| `platforms` | string[] | Supported target platforms (`["android"]`) |
| `android.minSdk` | number | Minimum Android SDK (e.g. 23) |
| `android.targetSdk` | number | Target Android SDK (e.g. 35) |
| `build.mode` | string | Default build mode (`debug` or `release`) |
| `dependencies` | object | Framework and package dependencies |

## Development Commands

```bash
# Preview on desktop with instant hot-reload
hyo run

# Build debug Android APK
hyo build

# Clean build artifacts
hyo clean
```
