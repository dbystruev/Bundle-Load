# Bundle-Load
Example of loading a bundle from remote server, unzipping it, loading a storyboard from the bundle, and instantiating initial view controller.

## Setup
To create a new bundle, follow [this advice](https://stackoverflow.com/questions/4888208/how-to-make-an-ios-asset-bundle?answertab=active#tab-top).

Zip your bundle.  Put it on the server.  Change [ViewController.swift](https://github.com/dbystruev/Bundle-Load/blob/master/Bundle%20Load/Controllers/ViewController.swift):

- Line 14: replace with a name of a bundle inside a ".zip" archive
- Line 15: replace with URL to a zipped bundle file
- Line 16: replace with your version URL text file

Version is a UTF8 text file with anything in it.  The bundle is loaded if version file has changed.  

## Thanks to
- [SSZipArchive](https://github.com/ZipArchive/ZipArchive.git) by [ZipArchive](https://github.com/ZipArchive)
