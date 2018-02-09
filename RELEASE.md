# Release Process

This document describes the release process for a new version of the Gini iOS SDK.
Before the release check that all features have been merged into master, tests and documentation are up to date.

1. Create a `release` branch.
2. Update changelog with last version and date
3. Update `podspec` with version used in 2.
4. Create a tag with the same version used in 2 and 3.
5. Merge `master` and `develop` into `release`.
6. Remove `release` branch and push all the branches including tags.
7. Wait for the Jenkins build job to succeed
8. Update documentation manually and verify that it was update successfully.
9. Push update to [Gini Podspec repo](https://github.com/gini/gini-podspecs) with `pod repo push gini-specs ./Gini-iOS-SDK.podspec`
10. Update version on gini.net/developers
