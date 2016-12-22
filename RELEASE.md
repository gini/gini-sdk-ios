# Release Process

This document describes the release process for a new version of the Gini iOS SDK.
Before the release check that all features have been merged into master, tests and documentation are up to date.

1. Create a release commit on `master` with the version name in the commit message
  * Optional: Make changes needed for the release
  * Update changelog and put {{version_and_date}} as the header, it will be replaced with the release version and date in the release Jenkins build job
2. Commit and push to `master`
3. Wait for the Travis CI build job to succeed
4. Run `gini-sdk-ios-release` job on Jenkins with the release version as a parameter
5. Verify online documentation, changelog and podspec have been updated
6. Update version on gini.net/developers
