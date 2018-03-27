.. _guide-getting-started:

===============
Public Key pinning
===============

The Gini iOS SDK allows you to enable public key pinning with the Gini API through the [TrustKit](https://github.com/datatheorem/TrustKit/) library. In case you want to implement it, first you have to add `pod Gini-iOS-SDK/Pinning` below `pod Gini-iOS-SDK` in your `Podfile`. Once you have imported it, you just need to pass a dictionary with all the parameters required into one of the `GINISDKBuilder` initializers, as follows:


.. code-block:: swift

    let trustKitConfig = [
                kTSKSwizzleNetworkDelegates: false,
                kTSKPinnedDomains: [
                    "gini.net": [
                        kTSKIncludeSubdomains:true,
                        kTSKEnforcePinning:true,
                        kTSKDisableDefaultReportUri:true,
                        kTSKPublicKeyAlgorithms: [kTSKAlgorithmRsa2048],
                        kTSKPublicKeyHashes: [
                            "yGLLyvZLo2NNXeBNKJwx1PlCtm+YEVU6h2hxVpRa4l4=",
                            "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="
                        ],]]] as [String : Any]

    let sdk = GINISDKBuilder.anonymousUser(withClientID: "your_client_id",
                                           clientSecret: "your_client_secret",
                                           userEmailDomain: "your_user_email_domain"
                                           publicKeyPinningConfig: trustKitConfig).build()


.. code-block:: obj-c

    NSDictionary *trustKitConfig = @{
    kTSKPinnedDomains: @{
            @"gini.net" : @{
                    kTSKIncludeSubdomains:@YES,
                    kTSKEnforcePinning:@YES,
                    kTSKDisableDefaultReportUri:@YES
                    kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                    kTSKPublicKeyHashes : @[
                            @"yGLLyvZLo2NNXeBNKJwx1PlCtm+YEVU6h2hxVpRa4l4=",
                            @"47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="
                            ],
                    }}};

    GiniSDK *sdk = [[GINISDKBuilder anonymousUserWithClientID:@"your_client_id"
                                                 clientSecret:@"your_client_secret"
                                              userEmailDomain:@"your_user_email_domain"
                                       publicKeyPinningConfig:trustKitConfig] build];

If `kTSKEnforcePinning` is set to `false`, any SSL connection will be block even if the pinning fails. When it is enabled, it requires at least two hashes (the second one is a backup hash).
When using `TrustKit` some messages are shown in the console log. It is possible to either specify a custom log for messages or disable it altogether (setting it as nil). To do so just use the `TrustKit.setLoggerBlock` method before initializing the `trustKitConfig`.

The Gini API public key SHA256 hash in Base64 encoding can be extracted with the following `openssl` commands:

.. code-block:: bash

    openssl s_client -servername gini.net -connect gini.net:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64