# BTXCustomerMessengerKit

`BTXCustomerMessengerKit` embeds BTX Customer Messages in iOS apps.

The package targets iOS 17 or newer.

Swift Package Manager installs a prebuilt `XCFramework` release from GitHub Releases through the public wrapper repo.

## Add the package

1. In Xcode, go to `File` then `Add Package Dependencies...`.
2. Enter `https://github.com/secondcontext/btx-messenger-ios-sdk.git`.
3. Select `BTXCustomerMessengerKit` and attach the library product to your app target.

## Configure the messenger

```swift
import SwiftUI
import BTXCustomerMessengerKit

private let messengerConfiguration = BTXCustomerMessengerConfiguration(
    apiBaseURL: URL(string: "https://your-btx-host.example.com")!,
    appID: "app_123",
    apiKey: "api_key_123",
    customer: BTXCustomerMessengerCustomer(
        externalID: "customer_123",
        name: "Taylor",
        email: "taylor@example.com"
    ),
    appContext: BTXCustomerMessengerAppContext(
        appVersion: "1.0.0",
        buildNumber: "42",
        attributes: [
            "platform": "ios",
            "bundleId": "com.example.app"
        ]
    )
)

struct SupportRootView: View {
    @StateObject private var messenger: BTXCustomerMessenger

    init() {
        _messenger = StateObject(
            wrappedValue: BTXCustomerMessenger(configuration: messengerConfiguration)
        )
    }

    var body: some View {
        NavigationStack {
            Button("Open Customer Messages") {
                messenger.present()
            }
        }
        .btxCustomerMessenger(messenger, title: "Customer Messages")
    }
}
```

Create one long-lived `BTXCustomerMessenger` for the current signed-in user, mount it once per app scene near the app root, then open it from a host-app support or messages entry point with `messenger.present()`.

Recreate the messenger only when `apiBaseURL`, `appID`, `apiKey`, or `customer.externalID` changes.

The configuration requires:

- `apiBaseURL`
- `appID`
- `apiKey`
- `customer`
- `appContext`

`projectID` is optional and is not required for the standard public SDK integration path.

## Host app responsibilities

The host app owns:

- the signed-in customer identity
- app version and build metadata
- where the user opens Customer Messages from
- mounting the SDK once per app scene near the app root
- notification permission and APNs registration

The SDK owns:

- thread bootstrap, creation, append, and refresh calls
- realtime connection lifecycle
- local thread and message state
- foreground reply toasts
- opening the correct thread after a notification tap

## Push notifications are optional

You do not need push notifications to:

- install `BTXCustomerMessengerKit`
- mount `.btxCustomerMessenger(...)`
- create and continue threads
- receive live updates while the app is open
- show foreground in-app toasts while the messenger is mounted

Only add push when you want replies to reach users while their app is backgrounded or closed.

Push setup has three parts:

1. In BTX desktop, go to `Customer Messages -> Clients`, create or update an `iOS` client, then save the app name, bundle ID, Apple Team ID, APNs Auth Key ID, and APNs Auth Key `.p8`.
2. In Xcode, enable `Push Notifications` and `Background Modes` with `Remote notifications` for the same bundle ID.
3. In the host app, request notification permission, register with APNs, and forward APNs callbacks into `BTXCustomerMessenger`.

### Request permission and register with APNs

```swift
import UIKit
import UserNotifications

@MainActor
func enableCustomerMessagesPush() async {
    let center = UNUserNotificationCenter.current()
    let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    guard granted == true else { return }
    UIApplication.shared.registerForRemoteNotifications()
}
```

Call `await enableCustomerMessagesPush()` once after the host app has a long-lived `BTXCustomerMessenger` for the current signed-in customer.

### Forward APNs events into the SDK

```swift
import UIKit
import UserNotifications
import BTXCustomerMessengerKit

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var messenger: BTXCustomerMessenger?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            _ = messenger?.handleLaunchNotification(remoteNotification)
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard let messenger else { return }
        Task {
            try? await messenger.registerPushDeviceToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if messenger?.handleRemoteNotification(userInfo) == true {
            completionHandler(.noData)
            return
        }

        completionHandler(.noData)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if messenger?.handleRemoteNotification(notification.request.content.userInfo) == true {
            completionHandler([])
            return
        }

        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if messenger?.handleNotificationResponse(response) == true {
            completionHandler()
            return
        }

        completionHandler()
    }
}
```

Keep the same long-lived `BTXCustomerMessenger` instance available to the app delegate or push coordinator. All SDK push APIs should forward into that same messenger instance.

Use the push APIs as follows:

- `registerPushDeviceToken(_:)` when APNs gives the host app a device token
- `handleLaunchNotification(_:)` from `launchOptions[.remoteNotification]` when the app cold-starts from a notification tap
- `handleRemoteNotification(_:)` for incoming push payloads while the app is running
- `handleNotificationResponse(_:)` for notification taps so the SDK can present the messenger and open the correct thread
- `unregisterPushDevice()` before discarding the messenger when the signed-in customer changes or signs out

The host app still owns requesting notification permission and calling `UIApplication.registerForRemoteNotifications()`. The APNs token you forward must come from a bundle ID that exactly matches the bundle ID configured on the BTX client. Debug builds register as `development` automatically. TestFlight and App Store builds register as `production`.
