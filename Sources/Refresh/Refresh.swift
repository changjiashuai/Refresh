
import SwiftUI

public struct Refresh {
}

@available(iOS 13.0, *)
public typealias RefreshHeader = Refresh.Header

@available(iOS 13.0, *)
public typealias RefreshFooter = Refresh.Footer

@available(iOS 13.0, *)
extension Refresh {
    
    public struct Header<Content: View>: View {
        
        @Environment(\.headerRefreshControl) var refreshControl
        @Binding var refreshing: Bool
        
        let action: () -> Void
        let content: (CGFloat) -> Content
        
        public init(refreshing: Binding<Bool>,
             action: @escaping () -> Void,
             @ViewBuilder content: @escaping (CGFloat) -> Content
        ) {
            self.action = action
            self.content = content
            self._refreshing = refreshing
        }
        
        public var body: some View {
            if refreshControl.isRefreshing, !refreshing, refreshControl.progress > 1 {
                //start refresh
                DispatchQueue.main.async {
                    self.refreshing = true
                    self.action()
                }
            }
            
            return Group {
                if refreshControl.isEnabled {
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        content(refreshControl.progress)
                            .opacity(opacity)
                    }
                    .frame(maxWidth: .infinity)
                }else {
                    EmptyView()
                }
            }
            .listRowInsets(.zero)
            .anchorPreference(key: HeaderAnchorPrefenceKey.self, value: .bounds, transform: { anchor in
                [.init(bounds: anchor, isRefreshing: self.refreshing)]
            })
        }
        
        /// if start refreshing show, else hide
        private var opacity: Double {
            (!refreshing && refreshControl.isRefreshing) || (refreshControl.progress == 0) ? 0 : 1
        }
    }
}

@available(iOS 13.0, *)
extension Refresh {
    
    public struct Footer<Content: View>: View {
        @Environment(\.footerRefreshControl) var refreshControl
        @Binding var refreshing: Bool
        
        let action: () -> Void
        let content: () -> Content
        
        private var noMore: Bool = false
        private var thresholdOffset: CGFloat = 0
        
        public init(
            refreshing: Binding<Bool>,
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self._refreshing = refreshing
            self.action = action
            self.content = content
        }
        
        public func noMore(_ noMore: Bool) -> Self {
            var view = self
            view.noMore = noMore
            return view
        }
        
        public func preload(offset: CGFloat) -> Self {
            var view = self
            view.thresholdOffset = offset
            return view
        }
        
        public var body: some View {
            if !noMore, refreshControl.isRefreshing, !refreshing {
                //start refresh
                DispatchQueue.main.async {
                    self.refreshing = true
                    self.action()
                }
            }
            
            return Group {
                if refreshControl.isEnabled {
                    VStack(alignment: .center, spacing: 0) {
                        if refreshing || noMore {
                            //show footer view
                            content()
                        }else {
                            EmptyView()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }else {
                    EmptyView()
                }
            }
            .listRowInsets(.zero)
            .anchorPreference(key: FooterAnchorPreferenceKey.self, value: .bounds, transform: { anchor in
                if self.noMore || self.refreshing {
                    return []
                }else {
                    return [.init(bounds: anchor, thresholdOffset: self.thresholdOffset, isRefreshing: self.refreshing)]
                }
            })
        }
    }
}

@available(iOS 13.0, *)
extension View {
    
    func clipped(_ value: Bool) -> some View {
        if value {
            return AnyView(self.clipped())
        }else {
            return AnyView(self)
        }
    }
}

@available(iOS 13.0, *)
extension EdgeInsets {
    
    static var zero: EdgeInsets {
        .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
