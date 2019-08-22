# Bundle-Load
Example of loading a bundle from remote server, unzipping it, loading a storyboard from the bundle, and instantiating initial view controller.

## Setup
To create a new bundle, follow [this advice](https://stackoverflow.com/questions/4888208/how-to-make-an-ios-asset-bundle?answertab=active#tab-top).

Zip your bundle and put it on the server somewhere.  Change [ViewController.swift](https://github.com/dbystruev/Bundle-Load/blob/master/Bundle%20Load/Controllers/ViewController.swift):

- Line 13: put your bundle name.
- Line 18: put your bundle URL.  Make sure last component of bundle URL is bundle name with ".zip"
- Run It!

## Thanks to
- [SSZipArchive](https://github.com/ZipArchive/ZipArchive.git) by [ZipArchive](https://github.com/ZipArchive)
