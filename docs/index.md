## Integrate the Gini iOS SDK

Import the header in your app delegate header file

    #import <GiniSDK.h>

Create an instance of the GiniSDK with your chosen clientID and the custom URL scheme

    GiniSDK *giniSDK = [GiniSDK giniSDKWithAppURLScheme:@"YOUR_APP_URL_SCHEME" clientID:@"YOUR_CLIENT_ID"];

## Implement the custom URL scheme

Please notice that your app needs to implement a custom URL scheme in order to get the session information when the
user logs in to Gini. Therefore, you need to provide a redirect_uri when registering you app with Gini. The
redirect_uri should be `your-app-scheme://gini-authorization-finished` (where "your-app-scheme"
is replaced with your actual custom URL scheme).

In your app, register your custom URL scheme together with an abstract name of the URL scheme (reverse DNS-style of the 
identifier), by adding the information to your Plist file. Please refer to the 
[section "Implementing Custom URL Schemes" in the Apple Documentation](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html#//apple_ref/doc/uid/TP40007072-CH7-SW50) 
for details.

	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>YOUR_IDENTIFIER</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>YOUR_APP_URL_SCHEME</string>
			</array>
		</dict>
	</array>


Your app needs to repond on the app delegate to the incoming URL. Do this by implementing the following delegate method

    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        return [_giniSDK.sessionManager handleURL:url];
    }
