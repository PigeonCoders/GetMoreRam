# Get More Ram
A simple [StosSign](https://github.com/stossy11/StosSign) wrapper app that allows you to enable "Increased Memory Limit" for your sideloaded apps without using Xcode.

## Windows / iTunes authentication fork

This fork defaults to the following SideStore configuration:

```text
Client Info: <PC> <Windows;6.2(0,0);9200> <com.apple.AuthKit/1 (com.apple.iTunes/12.12.4.1)>
User Agent: akd/1.0 CFNetwork/808.1.4
```

Both values are editable and saved under **Settings → Authentication**. They apply to anisette provisioning, GrandSlam sign-in (including the app-token request), and trusted-device/SMS two-factor requests. Changes take effect on the next sign-in. The server URL is also reread on each sign-in. Developer Services retains StosSign's existing Xcode user agent.

The pinned [StosSign authentication patch](https://github.com/failury/StosSign/commit/56479ccad9b45bcb81ee761d019e64c46ab392f8) adds an optional user-agent override and retains the original defaults for other clients. GetMoreRam's `INCREASED_MEMORY_LIMIT` capability operation is unchanged. Authentication diagnostics omit raw anisette secrets, and generated timestamps use UTC.

### Download and install

1. Download `GetMoreRam-WindowsAuth.ipa` from this fork's [Releases](https://github.com/failury/GetMoreRam/releases). Each build is also available as an Actions artifact.
2. Install the IPA through SideStore using the Apple ID that owns LiveContainer's App ID.
3. Open GetMoreRam → **Settings**. The Windows / iTunes values above are already filled in. Confirm the anisette server matches your working server, then tap **Sign in** and complete two-factor verification.
4. Open **App IDs**, tap **Refresh**, and select LiveContainer's exact App ID.
5. Tap **Add Increased Memory Limit**.
6. Refresh/re-sign LiveContainer in SideStore so its new provisioning profile contains the capability. If reinstalling is necessary, back up its containers and app data first.
7. Re-enable JIT using your working StikDebug connection and test the emulator.

The IPA is unsigned; SideStore signs it during installation. This setting requests a higher memory limit and does not add physical RAM or guarantee a specific limit. Apple ID authentication, capability acceptance, provisioning-profile regeneration, and the resulting emulator behavior require an on-device test. No Apple credentials are required for builds.

The existing **Import SideStore Account** option remains available for SideStore's exported account JSON. It imports credentials and provisioning identity; it does not import `.sideconf` settings.

### Build

The GitHub Actions workflow creates an unsigned arm64 archive, packages the IPA, uploads an artifact with its SHA-256 checksum, and publishes a release on pushes to `main`.

For a local build with Xcode installed:

```sh
xcodebuild archive -project GetMoreRam.xcodeproj -scheme GetMoreRam \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/GetMoreRam.xcarchive \
  CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
mkdir -p build/ipa/Payload dist
cp -R build/GetMoreRam.xcarchive/Products/Applications/GetMoreRam.app build/ipa/Payload/
ditto -c -k --norsrc --keepParent build/ipa/Payload dist/GetMoreRam-WindowsAuth.ipa
```

### Implementation comparison

- [SideStore's anisette configuration](https://github.com/SideStore/SideStore/blob/develop/SideStore/Core/Anisette/AnisetteConfigManager.swift) resolves editable client-info and user-agent headers. This fork follows that approach with the supplied defaults.
- [iLoader's sign-in](https://github.com/nab138/iloader/blob/main/src-tauri/src/account.rs) delegates authentication and remote-v3 anisette to the Rust `isideload` library. Replacing this Swift app's authentication stack with that Rust stack is a larger change; the header patch keeps GetMoreRam's existing sign-in, two-factor, account import, and capability APIs.

Request-construction tests in the StosSign fork verify the headers for GrandSlam init, completion, app tokens, and both two-factor flows. Configuration validation can be checked locally:

```sh
swiftc GetMoreRam/AuthenticationConfiguration.swift Tests/AuthenticationConfiguration/main.swift -o /tmp/getmoreram-configuration-tests
/tmp/getmoreram-configuration-tests
```

# How to use
1. Sideload this app
2. Go to settings, sign in your account that you used to sign the app you want to enable "Increased Memory Limit"
3. Go to "App IDs" page
4. Tap Refresh
5. Tap the app you want to enable "Increased Memory Limit"
6. Tap "Add Increased Memory Limit"
7. Reinstall the app from SideStore/AltStore
8. Check if you have "Increased Memory Limit"

# Credits
Stossy11 - For StosSign.
SideStore - Anisette Data fetching codes are stolen from SideStore
