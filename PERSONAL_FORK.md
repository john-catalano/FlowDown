# Personal FlowDown fork

This checkout builds and deploys through Bitrig, signed with the Apple Development identity already in Xcode.

| Setting | Value |
| --- | --- |
| Team | John Joseph Catalano (`HZKNJGXMBK`) |
| App | `app.bitrig.johncatalano.flowdown` |
| Translation extension | `app.bitrig.johncatalano.flowdown.FlowDownTranslationProvider` |
| Widgets | `app.bitrig.johncatalano.flowdown.FlowDownWidgets` |
| Unit tests | `app.bitrig.johncatalano.flowdown.FlowDownUnitTests` |
| App group | `group.app.bitrig.johncatalano.flowdown` |
| CloudKit container | `iCloud.app.bitrig.johncatalano.flowdown.sync` |

Debug builds keep FlowDown's existing sync code and use the CloudKit **Development** environment. Release and archive builds use **Production**. Do not deploy the development schema to production until a TestFlight or App Store release.

Overrides live in `FlowDown/Configuration/Developer.xcconfig`. `Development.xcconfig` and `Release.xcconfig` include that file after `Base.xcconfig`, so upstream can keep its own team and bundle identifier in `Base.xcconfig`.

## Build and deploy

Check out the Swift package submodules before the first build. The FlowDown scheme also runs `git submodule update`, but Xcode resolves packages before that script, so a missing `Frameworks/ChatClientKit` checkout fails with `Missing package product 'ChatClientKit'`.

```sh
git submodule update --init --recursive
```

From the repository root:

```sh
make bitrig-preview      # iPhone and iPad simulator preview
make bitrig-build-ios    # device build, no launch
make bitrig-provision    # register iCloud, CloudKit, push, and the app group
make bitrig-build-mac    # Mac Catalyst, when Bitrig accepts that destination
make bitrig-test         # unit tests on the iOS simulator
```

Bitrig lists this scheme as an iOS app. Mac Catalyst is enabled on the target, but Bitrig's macOS destination is not available for it, so `bitrig preview -platform macOS` cannot launch the Mac app. Use **Run on…** for your iPhone and iPad. For the Mac, use Xcode's My Mac (Mac Catalyst) run destination, or `make build-catalyst` from the Makefile.

After identifiers change, run `make bitrig-provision` once so Apple registers the app group and CloudKit container. The simulator does not register those capabilities by itself.

## Verify iCloud sync

### Bitrig preview crash investigation (2026-10-16)

`make bitrig-preview` completed successfully with the iOS 27 simulator SDK.
The build log `2026-10-16T10-31-14-00e72c87.log` contains one nonfatal
`cmark-gfm` module-map warning and no build errors. Launch verification remains
blocked: the simulator stayed on its home screen and returned no app run log.

Bitrig 0.29.0 (2900), rather than FlowDown, crashed at 10:31:42 and again at
10:33:40 (+0800). Both macOS diagnostic reports identify
`/Applications/Bitrig.app/Contents/MacOS/Bitrig`, `EXC_CRASH` / `SIGABRT`, and
`swift_task_reportUnexpectedExecutor`. The next two frames have Bitrig image
offsets 21535632 and 21634248, matching the earlier October 15 reports.
These reports establish a host concurrency failure; they do not establish
which Bitrig operation causes it. A Bitrig fix is needed before preview launch
can be verified reliably. Repeated preview attempts are not a useful workaround.

The tracked ChatClientKit SwiftPM workspace and schemes deleted during the
earlier investigation were restored. No package source or dependency pin was
changed. The successful preview build above preceded that restoration.

1. Install a Debug build on the iPhone and the iPad with **Run on…**, using the same Apple ID in Settings → iCloud on both devices.
2. In FlowDown, open Settings → Data Control and turn on **Enable iCloud Sync**.
3. Create a conversation on one device, leave the app in the foreground on the other, and confirm the conversation appears.
4. The Mac build must use the same bundle identifier, app group, and container. It syncs only with other builds of this fork, not with the App Store copy of FlowDown.

Development data is not visible to TestFlight or App Store builds. Before the first production release, deploy the schema from the Development environment in [CloudKit Console](https://icloud.developer.apple.com/dashboard/).

## Take upstream updates

```sh
git remote add upstream https://github.com/Lakr233/FlowDown.git   # once
git fetch upstream
git merge upstream/main
git submodule update --init --recursive
```

Keep `FlowDown/Configuration/Developer.xcconfig`. If `Base.xcconfig` conflicts, keep upstream's team and bundle identifier, and keep the `APP_GROUP_IDENTIFIER` setting so the personal file can override it. Extension bundle identifiers in `FlowDown.xcodeproj` should stay `$(inherited).<suffix>` so they follow the personal app id.
