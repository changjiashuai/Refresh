# Refresh

A custom SwiftUI Refresh Control.

## iPhone Preview

## Features

#### Availables

## Installation

#### Requirements
- iOS 13.0+ / macOS 10.15.4+
- Xcode 11.2+
- Swift 5+

#### Swift Package Manager

In Xcode 11 or grater, in you project, select: `File > Swift Packages > Add Pacakage Dependency`.

```
https://github.com/changjiashuai/Refresh.git
```

##  How to Use

To use the **Refresh** just enableRefresh on ScrollView:

```Swift

@State private var items: [Item] = []
@State private var headerRefreshing: Bool = false
@State private var footerRefreshing: Bool = false
@State private var noMore: Bool = false

ScrollView {
    if items.count > 0 {
        RefreshHeader(refreshing: $headerRefreshing, action: {
            self.reload()
        }) { progress in
            if self.headerRefreshing {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
            } else {
                Text("pulling progress: \(progress)")
            }
        }
    }
    
    ForEach(items) { item in
        SimpleCell(item: item)
    }
     
    if items.count > 0 {
        RefreshFooter(refreshing: $footerRefreshing, action: {
            self.loadMore()
        }) {
            if self.noMore {
                Text("No more data !")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            }
        }
        .noMore(noMore)
        .preload(offset: 20)
    }
}
.enableRefresh()
```
