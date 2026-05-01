# BTX iOS SDK

`BTXClientKit` is the BTX iOS SDK for embedding BTX-powered customer conversations, thread context, activity logging, and branded support surfaces inside iOS apps.

The package targets iOS 17 or newer.

The public package is distributed as a Swift Package Manager wrapper around a versioned `BTXClientKit` XCFramework. Host apps only talk to BTX-owned HTTP and SSE endpoints. They do not receive Supabase credentials or vendor-specific realtime configuration.

## What ships today

The SDK currently includes:

- a long-lived `BTXClient` runtime for the current signed-in customer
- thread list and thread detail sync
- creating new threads and sending follow-up messages
- launch-time thread title, intro cards, and hidden thread attributes
- host-side activity logging
- image attachments in the built-in composer
- runtime theming for the customer surface
- optional APNs push delivery and notification routing

## Add the package

1. In Xcode, go to `File` then `Add Package Dependencies...`.
2. Enter `https://github.com/secondcontext/btx-ios-sdk.git`.
3. Select `BTXClientKit` and attach the library product to your app target.

Choose the package requirement that matches how you want updates to land in your app. Use an exact version when you want manual control over each SDK upgrade, or a semantic-version rule when you want Xcode to pick up newer compatible tags automatically.

## Configure the client

```swift
import SwiftUI
import BTXClientKit

private let clientConfiguration = BTXClientConfiguration(
    apiBaseURL: URL(string: "https://your-btx-host.example.com")!,
    appID: "app_123",
    apiKey: "api_key_123",
    customer: BTXCustomer(
        externalID: "customer_123",
        name: "Taylor",
        email: "taylor@example.com"
    ),
    appContext: BTXAppContext(
        appVersion: "1.0.0",
        buildNumber: "42",
        attributes: [
            "platform": "ios",
            "bundleId": "com.example.app"
        ]
    ),
    theme: BTXClientTheme(
        backgroundColor: .black,
        primaryTextColor: .white,
        secondaryTextColor: Color.white.opacity(0.7)
    )
)

struct SupportRootView: View {
    @StateObject private var client: BTXClient

    init() {
        _client = StateObject(
            wrappedValue: BTXClient(configuration: clientConfiguration)
        )
    }

    var body: some View {
        NavigationStack {
            Button("Open BTX") {
                client.present()
            }
        }
        .btxClient(client, title: "Support")
    }
}
```

Create one long-lived `BTXClient` for the current signed-in user, mount it once per app scene near the app root, then open it from your host-app entry points with `client.present(...)`.

Recreate the client only when one of these changes:

- `apiBaseURL`
- `appID`
- `apiKey`
- `customer.externalID`

The configuration requires:

- `apiBaseURL`
- `appID`
- `apiKey`
- `customer`
- `appContext`

`projectID` is optional and is not required for the standard public SDK integration path.

## Open a thread with BTX context

Use `BTXLaunchContext` when the host app wants a new thread to open around a known topic:

```swift
client.present(
    launchContext: BTXLaunchContext(
        entryPoint: "order_detail",
        sourceType: "order",
        sourceID: "order_123",
        threadTitle: "Order Support",
        threadIntro: .card(
            title: "Ordered on Apr 30",
            subtitle: "Printing tomorrow",
            imageURL: "https://cdn.example.com/orders/order-123.jpg"
        ),
        threadAttributes: [
            "user": .object([
                "id": .string("user_123")
            ]),
            "order": .object([
                "id": .string("order_123"),
                "status": .string("pending"),
                "adminURL": .string("https://internal.example.com/orders/order_123")
            ])
        ]
    )
)
```

Use launch context when you want BTX to know why the user opened the thread:

- `threadTitle` sets the thread title shown in the customer surface
- `threadIntro` renders customer-visible context at the top of a new thread
- `threadAttributes` carries hidden structured metadata for the operator side

## Record host-app activity

The SDK can also record customer activity from the host app:

```swift
client.recordActivity(
    BTXActivity(
        kind: "order_detail_viewed",
        title: "Viewed order detail",
        detail: "Order 5019c8b5-fc51-4d90-8a4b-46e76fbed2e9",
        attributes: [
            "orderId": "5019c8b5-fc51-4d90-8a4b-46e76fbed2e9",
            "orderStatus": "pending"
        ]
    )
)
```

Use activity logging for high-signal host events such as:

- viewing an order or account screen
- launching BTX from a specific flow
- completing a purchase or support-relevant action

## Theme the customer surface

`BTXClientTheme` lets the host app make the customer messenger feel more native without rebuilding the UI shell:

```swift
theme: BTXClientTheme(
    backgroundColor: .black,
    primaryTextColor: .white,
    secondaryTextColor: Color.white.opacity(0.7),
    heroFont: .init(postScriptName: "AwesomeSerif-MediumTall"),
    titleFont: .init(postScriptName: "BagossStandard-Medium"),
    bodyFont: .init(postScriptName: "BagossStandard-Regular"),
    emptyStateLogo: .init(assetName: "EscargotMark"),
    emptyStateAccentColor: Color.green
)
```

The current theming surface covers:

- messenger background
- key header and empty-state text
- thread-intro text
- empty-state logo and accent treatment

The composer layout and chat bubble structure intentionally stay BTX-owned.

## Image attachments

The built-in composer supports attaching up to 4 images from the photo library. Image-only messages are allowed.

The SDK prepares selected images before sending:

- images are downsampled off the main actor
- outgoing payloads are JPEG
- each prepared image must fit under the SDK client-side size limit
- attachments are sent with the existing `images` request key

The CustomerMessenger API returns message attachments in thread payloads, and the SDK renders them in the conversation timeline.

## Push notifications are optional

You do not need push notifications to:

- install `BTXClientKit`
- mount `.btxClient(...)`
- create and continue threads
- receive live updates while the app is open
- show foreground in-app toasts while the messenger is mounted

Only add push when you want replies to reach users while their app is backgrounded or closed.

Push setup has three parts:

1. In BTX desktop, go to `Customer Messages -> Clients`, create or update an `iOS` client, then save the app name, bundle ID, Apple Team ID, APNs Auth Key ID, and APNs Auth Key `.p8`.
2. In Xcode, enable `Push Notifications` and `Background Modes` with `Remote notifications` for the same bundle ID.
3. In the host app, request notification permission, register with APNs, and forward APNs callbacks into `BTXClient`.

### Request permission and register with APNs

```swift
import UIKit
import UserNotifications

@MainActor
func enableBTXPush() async {
    let center = UNUserNotificationCenter.current()
    let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    guard granted == true else { return }
    UIApplication.shared.registerForRemoteNotifications()
}
```

Call `await enableBTXPush()` once after the host app has a long-lived `BTXClient` for the current signed-in customer.

### Forward APNs events into the SDK

```swift
import UIKit
import UserNotifications
import BTXClientKit

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var client: BTXClient?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            _ = client?.handleLaunchNotification(remoteNotification)
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard let client else { return }
        Task {
            try? await client.registerPushDeviceToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if client?.handleRemoteNotification(userInfo) == true {
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
        if client?.handleRemoteNotification(notification.request.content.userInfo) == true {
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
        if client?.handleNotificationResponse(response) == true {
            completionHandler()
            return
        }

        completionHandler()
    }
}
```

Keep the same long-lived `BTXClient` instance available to the app delegate or push coordinator. All SDK push APIs should forward into that same client instance.

Use the push APIs as follows:

- `registerPushDeviceToken(_:)` when APNs gives the host app a device token
- `handleLaunchNotification(_:)` from `launchOptions[.remoteNotification]` when the app cold-starts from a notification tap
- `handleRemoteNotification(_:)` for incoming push payloads while the app is running
- `handleNotificationResponse(_:)` for notification taps so the SDK can present the messenger and open the correct thread
- `unregisterPushDevice()` before discarding the messenger when the signed-in customer changes or signs out

The host app still owns requesting notification permission and calling `UIApplication.registerForRemoteNotifications()`. The APNs token you forward must come from a bundle ID that exactly matches the bundle ID configured on the BTX client. Debug builds register as `development` automatically. TestFlight and App Store builds register as `production`.
