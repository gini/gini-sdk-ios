Architecture
------------

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
described in the [integration guide](docs/1.%20Integration%20Guide.html)). The `GiniSDK` instance uses an injector (which
is provided at the instance's `injector` property) to create the manager instances and to manage the dependencies
between the managers and makes those manager instances available as properties.


How to start
------------

We recommend that you read the [integration guide](docs/1.%20Integration%20Guide.html) for more details how to
integrate the SDK and the [Working with tasks programming guide](docs/2.%20Working%20with%20tasks.html) since the SDK
makes heavy use of the concept of tasks.


Support and Feedback
--------------------

We are happy to hear from you. The SDK's source files are [hosted at github](https://github.com/gini/gini-sdk-ios). Feel
free to contact Gini at hello@gini.net (you can write in German or English) if you have questions, experience problems
or need support.
