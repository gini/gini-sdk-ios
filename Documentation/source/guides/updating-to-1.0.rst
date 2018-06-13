.. _guide-updating-to-1.0:

===============
Updating to 1.0
===============

## What's new?
- Added **Multipage** support, which introduces a new way to analyze documents (see [Partial and Composite documents](##partial-and-composite-documents) below).
- Updated **Bolts** to 1.9 (see more details [here](https://github.com/BoltsFramework/Bolts-ObjC/blob/master/CHANGELOG.md))
- Now it is possible to provide a cancellation token to every task

## Partial and Composite documents

Now for every page a **Partial** document has to be created with
`createPartialDocumentWithFilename:fromData:docType:cancellationToken:` method, even if the analysis implies only one page.
Once you have created one or several partial documents, you have to create a **Composite** document. To do so, you just need to pass an array of `GINIPartialDocumentInfo` (in the correct order) to the `createCompositeDocumentWithPartialDocumentsInfo:fileName:docType:cancellationToken:``.

Finally, you can get the extractions for that **Composite** documents with `getExtractionsForDocument:` as usual.

## Breaking changes
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
