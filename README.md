ADTickerLabel
=============
-------------

An objective-c UIView which provide a mechanism to show numbers with rolling effect, like in counter. Click to see video

[![](https://dl.dropbox.com/u/25847340/ADTickerLabel/screenshot-thumb.png)](https://dl.dropbox.com/u/25847340/ADTickerLabel/video.mp4)

------------
Requirements
============

ADTickerLabel works on any iOS version only greater or equal than 7.0 and is compatible with only ARC projects. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* CoreGraphics.framework
* QuartzCore.framework

You will need LLVM 3.0 or later in order to build ADTickerLabel.

------------------------------------
Adding ADGraphView to your project
====================================

From CocoaPods
------------

Add `pod 'ADTickerLabel'` to your Podfile or `pod 'ADTickerLabel', :head` if you're feeling adventurous.

Source files
------------

Another way to add the ADTickerLabel to your project is to directly add the source files and resources to your project.

1. Download the [latest code version](https://github.com/Antondomashnev/ADTickerLabel/downloads) or add the repository as a git submodule to your git-tracked project.
2. Open your project in Xcode, than drag and drop ADTickerLabel.h and ADTickerLabel.m files onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project.
3. Include ADTickerLabel wherever you need it with `#import "ADTickerLabel.h"`.

-----
Usage
=====

```objective-c
/*
 Width and height calculates automatically after you have set the font and characterWidth or if you want you can use default values
*/
ADTickerLabel *tickerLabel = [[ADTickerLabel alloc] initWithFrame: CGRectMake(100, 50, 0, 15)];
tickerLabel.font = [UIFont boldSystemFontOfSize: 12];
tickerLabel.characterWidth = 8;
tickerLabel.textColor = [UIColor whiteColor];
[self addSubview: tickerLabel];

tickerLabel.text = @"1908";
```

Also you can see the example of usage in ViewController.m in demo project.

-------
License
=======

This code is distributed under the terms and conditions of the MIT license.

----------
Change-log
==========

**Version 0.67 @ 21.1.15

- Update to iOS 7 (min) and 64bits architecture.

**Version 0.59 @ 22.6.13

- Add support text changing animation speed.

**Version 0.5** @ 10.6.13

- Initial release.
