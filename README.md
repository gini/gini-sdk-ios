# Gini iOS SDK

An SDK for integrating Gini technology into other apps. With this SDK you will be able to extract semantic information from various types of documents.

The Gini iOS SDK works for both Objective-C and Swift apps.

## Register your App with Gini

See the [API Documentation](http://developer.gini.net/gini-api/html/guides/oauth2.html#first-of-all-register-your-application-with-gini).

## Architecture

The Gini iOS SDK provides several managers that are used to interact with the
[Gini API](http://developer.gini.net/gini-api/html/index.html). Those are:

- `GINIDocumentTaskManager`: A high-level manager for document-related tasks. Use this manager to integrate the Gini
  magic into your application. It is built upon the `GINIAPIManager` and the `GINISessionManager`.
- `GINIAPIManager`: A low-level manager which interacts with the Gini API and which directly returns the API responses
  without much interpretation of the response. Because of that, it is not recommended that you use this manager
  directly. Instead use the `GINIDocumentTaskManager` which offers much more sophisticated methods for dealing with
  documents and extractions.
- `GINISessionManager`: Handles login-related tasks.

You don't need to create those manager instances yourself (and it is not recommended to try it, since the managers have
non-trivial dependencies). Instead, create and use an instance of the `GiniSDK` class (as
described in the [integration guide](http://developer.gini.net/gini-sdk-ios/docs/guides/getting-started.html)). The `GiniSDK` instance uses an injector (which
is provided at the instance's `injector` property) to create the manager instances and to manage the dependencies
between the managers and makes those manager instances available as properties.

## Public Key pinning
The Gini iOS SDK allows you to enable public key pinning with the Gini API through the [TrustKit](https://github.com/datatheorem/TrustKit/) library. In case you want to implement it, you just need to pass a dictionary with all the parameters required into one of the `GINISDKBuilder` initializers, as follows:

**Swift**
```swift
let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "example.com": [
                    kTSKExpirationDate: "2017-12-01",
                    kTSKPublicKeyAlgorithms: [kTSKAlgorithmRsa2048],
                    kTSKPublicKeyHashes: [
                        "public_key_hash",
                        "backup_public_key_hash"
                    ],]]] as [String : Any]

let sdk = GINISDKBuilder.anonymousUser(withClientID: "your_client_id",
                                       clientSecret: "your_client_secret",
                                       userEmailDomain: "your_user_email_domain"
                                       publicKeyPinningConfig: trustKitConfig).build()

```

**Objective-C**

```objective-c
NSDictionary *trustKitConfig = @{
kTSKPinnedDomains: @{
        @"example.com" : @{
                kTSKIncludeSubdomains:@YES,
                kTSKEnforcePinning:@YES,
                kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                kTSKPublicKeyHashes : @[
                        @"public_key_hash",
                        @"backup_public_key_hash"
                        ],
                }}};

GiniSDK *sdk = [[GINISDKBuilder anonymousUserWithClientID:@"your_client_id"
                                             clientSecret:@"your_client_secret"
                                          userEmailDomain:@"your_user_email_domain"
                                   publicKeyPinningConfig:trustKitConfig] build];
```

When using `TrustKit` some messages are shown in the console log. It is possible to either specify a custom log for messages or disable it altogether (setting it as nil). To do so just use the `TrustKit.setLoggerBlock` method before initializing the `trustKitConfig`.

## Requirements
- iOS 8.0+
- Xcode 8.0+

## Documentation

Learn how to use the Gini API at the [Gini Developer Portal](http://developer.gini.net):

- [Gini iOS SDK Documentation](http://developer.gini.net/gini-sdk-ios/docs/)
- [Gini API Documentation](http://developer.gini.net/gini-api/)

## How to start

We recommend you read the [integration guide](http://developer.gini.net/gini-sdk-ios/docs/guides/getting-started.html) for more details on how to
integrate the SDK.

## Author

Gini GmbH, hello@gini.net

## License

Gini iOS SDK is released under the MIT license. See LICENSE for details.
