=========
Changelog
=========

1.2.0 (16-01-2019)
==================

Features
--------

- Added support for the accounting API.

1.1.0 (31-10-2018)
==================

Features
--------

- Added the possibility to add metadata information in document
  uploads

1.0.0 (06-07-2018)
==================

Features
--------

- Added multipage support
- Deprecated legacy methods for extractions
- Updated Bolts to 1.9.0
- Updated TrustKit to 1.5.3
- Added cancellation token.


0.6.0 (09-02-2018)
==================

Features
--------

- Added public key pinning with TrustKit.
- Removed certificate pinning implementation.
- Updated minimum iOS version from 7.0 to 8.0

0.5.2 (18-01-2018)
==================

Features
--------

- Added QR code analysis support.

0.5.1 (14-12-2017)
==================

Features
--------

- Added support for pinning with more than one certificate.

0.5.0 (12-12-2017)
==================

Features
--------

- Added certificate pinning.

0.4.1 (11-05-2017)
==================

Bugfixes
--------

- Added "paymentPurpose" as an acceptable feedback field in GINIDocumentTaskManager

0.4.0 (19-04-2017)
==================

Bugfixes
--------

- Changing the email domain will update the email address of the existing anonymous user.
- Gini API session is cached until expiration.

0.3.2 (15-12-2016)
==================

Features
--------

- Add note to documentation regarding integration with Xcode 8.


0.3.1 (26-10-2016)
==================

Bugfixes
--------

- Fix tests to run in iOS 10.
- Minor bugfixes.

0.3.0 (24-02-2016)
==================

Features
--------

- Added support for binary data to enable PDFs, UTF-8 text and images containing meta information.

0.2.10 (20-11-2015)
===================

Bugfixes
--------

- HTTP error reporting fixed.
