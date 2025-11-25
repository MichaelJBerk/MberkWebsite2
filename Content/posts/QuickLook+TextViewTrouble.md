---
title: QuickLook + TextView Trouble
date: 2023-02-05 21:00
description: The cursed combination of QuickLook and NSTextView leads to some undocumented issues....
tags: SwiftUI, AppKit, macOS, programming, QuickLook
---
QuickLook is a really useful technology on Apple's OSes, and thankfully, SwiftUI has official support for showing a QuickLook preview of an item: the [`quickLookPreview`](https://developer.apple.com/documentation/swiftui/view/quicklookpreview(_:in:)) modifier, bridging the two disparate ways that macOS and iOS use to show previews ([`QLPreviewPanel`](https://developer.apple.com/documentation/quicklookui/qlpreviewpanel) and [`QLPreviewController`](https://developer.apple.com/documentation/quicklook/qlpreviewcontroller)). However, when implementing this into a side-project of mine, I encountered a strange issue: For whatever, reason, the preview wouldn't activate on macOS unless the button was clicked twice.

<video controls preload="metadata">
<source src="QuickLookIssue.mov#t=0.1" type="video/mp4">
</video>

After a bunch of ugly experimentation with `QLPreviewPanel`, I eventually discovered the unlikely culprit: `NSTextView`. To understand why this happens, we'll need to look at how the QuickLook panel works under-the-hood.

So, why does this happen? `QLPreviewPanel` is a subclass of [`NSPanel`](https://developer.apple.com/documentation/appkit/nspanel), which is a very weird subclass of NSWindow that has a bunch of interesting behaviors (a topic for another day). An app has a single shared `QLPreviewPanel` instance, and you can use a class that conforms to `QLPreviewPanelDataSource` to provide it with your preview item(s). However, out-of-the-box, `QLPreviewPanel` traverses the app's Responder Chain to find an object that can control it. As it turns out, `NSTextView` has the private `quickLookPreviewableItemsInRanges:` method, which overrides whatever you're trying to set the QuickLook panel to, as long as an `NSTextView` is in focus. 

![Header](header.png)

When the panel appears empty, that's because the `NSTextView` doesn't have anything to provide it with. However, once the panel has been shown, if we set the data again, the QuickLook panel will now display the preview correctly. Interestingly, this doesn't happen with the out-of-the-box SwiftUI `TextEditor` view. However, my side-project needs to use a custom `NSViewRepresentable` for `NSTextView`, which is where I first discovered this issue. 

It's worth noting that this issue isn't exclusive to SwiftUI - as long as an `NSTextView` is focused when presenting a `QLPreviewPanel`, it will run into the same issue.

## Workaround

The simplest way I found to combat `quickLookPreviewableItems:` is to remove focus from the offending `NSTextView` before showing the view.

For context, this is what my view looked like before the workaround:

```swift
import SwiftUI
import QuickLook

struct ContentView: View {
    var docURL: URL
    
    @State var qlURL: URL?
    @State var showTextView = false
    @State var text = ""
    var body: some View {
        VStack {
            Button("Show QuickLook") {
                qlURL = docURL
            }
            //This is simple NSViewRepresentable for an NSTextView. 
            //Take a look at the sample project if you want to see it.
            TextView(text: $text)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .quickLookPreview($qlURL)
    }
}
```

To fix it, I've created a `@FocusState` property that controls which view is currently in focus (`textFocus`). By setting it to `false` before setting `qlURL`, we can ensure that the `TextView` is not focused when showing the panel, and will thus function as expected.

```Swift
struct ContentView: View {
    var docURL: URL
    
    @State var qlURL: URL?
    @State var showTextView = false
    @State var text = ""
    @FocusState var textFocus
    var body: some View {
        VStack {
            Button("Show QuickLook") {
                textFocus = false
                qlURL = docURL
            }
            TextView(text: $text)
                .focused($textFocus)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .quickLookPreview($qlURL)
    }
}
```

<video controls preload="metadata">
<source src="QuickLookFixed.mp4#t=0.1" type="video/mp4">
</video>

[**You can find a sample project with this fix here**](https://github.com/MichaelJBerk/QLTextViewTrouble)

It would be remiss if I didn't mention the other way around this problem: overriding `quickLookPreviewableItemsInRanges:` and having it return whatever items you want to preview. However, I personally don't recommend you do this. For one, `quickLookPreviewableItemsInRanges:` is an undocumented API, so its underlying functionality could theoretically change with any software update, and if you ever plan on publishing to the Mac App Store, it's probably best to not tempt fate by submitting this code to App Review. But beyond that, you'd have to come up with a mechanism for telling the `NSTextView` subclass that overrides the method what item you want to preview in the first place, and after hunting around for a solution to this problem, that's the last thing I want to do.