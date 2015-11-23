.. _guide-adding-licenses:

=======
License
=======

The Gini iOS SDK is licensed under the MIT License (MIT) and also integrates several third party libraries. To add all license notices and permissions required to your application you can either use the prebuild files provided by CocoaPods or you can add them manually.

.. note:: Irrespective of the option you choose always make sure to ship all license notices and permissions with your application.

Using CocoaPods
===============

CocoaPods makes it easy for you to integrate licensing notices into your application. After installing or updating the SDK, CocoaPods generates two ``Acknowledgements`` files for each target specified in your Podfile. There is a markdown file, for general consumption, as well as a property list file that can be added to a settings bundle.

All required licenses for the Gini iOS SDK will automatically be added to those files.

For further information on how to use CocoaPods to display acknowledgements inside your app or in the Settings application refer to the `CocoaPods Wiki on Github <https://github.com/CocoaPods/CocoaPods/wiki/Acknowledgements>`_.

Manually
========

If you prefer adding the licenses manually use the Markdown content provided here to satisfy all license requirements. 

.. literalinclude:: modules/_acknowledgements.rst
	:language: dtd