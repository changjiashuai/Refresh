//
//  RefreshModifier.swift
//  
//
//  Created by CJS on 2021/8/8.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct RefreshModifier: ViewModifier {
    
    enum ScrollDirection {
        case down
        case up
        case left
        case right
    }
    
    @Environment(\.defaultMinListRowHeight) var rowHeight
    
    @State private var id: Int = 0
    @State private var headerRefreshControl: HeaderControlEnvironmentKey.HeaderRefreshControl
    @State private var headerPadding: CGFloat = 0
    @State private var headerPreviousProgress: CGFloat = 0
    
    @State private var footerRefreshControl: FooterControlEnvironmentKey.FooterRefreshControl
    @State private var footerPreviousRefreshAt: Date?
    
    @State private var scrollDirection: ScrollDirection = .down
    
    let isEnabled: Bool
    
    init(enable: Bool) {
        isEnabled = enable
        _headerRefreshControl = State(initialValue: .init(isEnabled: enable))
        _footerRefreshControl = State(initialValue: .init(isEnabled: enable))
    }
    
    func body(content: Content) -> some View {
        return GeometryReader { proxy in
            content
                .environment(\.headerRefreshControl, self.headerRefreshControl)
                .environment(\.footerRefreshControl, self.footerRefreshControl)
                .padding(.top, self.headerPadding)
                .clipped(proxy.safeAreaInsets == .zero)
                .backgroundPreferenceValue(HeaderAnchorPrefenceKey.self) { anchor -> Color in
                    if scrollDirection == .down {
                        DispatchQueue.main.async {
                            self.updateHeaderRefreshControl(proxy: proxy, headerAnchor: anchor)
                        }
                    }
                    return Color.clear
                }
                .backgroundPreferenceValue(FooterAnchorPreferenceKey.self) { anchor -> Color in
                    if scrollDirection == .up {
                        DispatchQueue.main.async {
                            self.updateFooterRefreshControl(proxy: proxy, footerAnchor: anchor)
                        }
                    }
                    return Color.clear
                }
                .gesture(DragGesture().onChanged({ value in
                    let width = value.translation.width
                    let height = value.translation.height
                    if abs(width) > abs(height) { //horizitonal
                        if width > 0 {
                            scrollDirection = .right
                        } else {
                            scrollDirection = .left
                        }
                    } else { //vertical
                        if height > 0 {
                            scrollDirection = .down
                        } else {
                            scrollDirection = .up
                        }
                    }
                }))
                .id(self.id)
        }
    }
    
    func updateHeaderRefreshControl(proxy: GeometryProxy, headerAnchor: HeaderAnchorPrefenceKey.Value) {
        //1. guard header view showing
        guard let headerView = headerAnchor.first else {
            return
        }
        
        //2. guard footer view is not refreshing
        guard !footerRefreshControl.isRefreshing else {
            return
        }
        
        //3. get header view bounds
        let bounds = proxy[headerView.bounds]
        
        //4. temp headerRefreshControl to record property changed
        var refreshControl = headerRefreshControl
        
        //5. calculate header view visible height: (bounds.maxY / bounds.height)
        /// 0 <= progress < 1: visibling
        /// progress = 1: full visible
        /// progress > 1: visible range > headerView.height
        refreshControl.progress = max(0, bounds.maxY / bounds.height)
        
        //6. if inner refresh state is not equal header view refresh state then update refresh state
        if refreshControl.isRefreshing != headerView.isRefreshing {
            refreshControl.isRefreshing = headerView.isRefreshing
            
            //6.1 if outer not need to refresh then immediately hide header view
            if !headerView.isRefreshing {
                id += 1
                DispatchQueue.main.async {
                    self.headerRefreshControl.progress = 0
                }
            }
        } else {
            //7. satisfy refresh condition
            let canRefreshing = refreshControl.isRefreshing
            //8. continuous pull down
            let continuousPulling = headerPreviousProgress > 1 && (1..<headerPreviousProgress ~= refreshControl.progress)
            refreshControl.isRefreshing = canRefreshing || continuousPulling
        }
        
        //9. if is refreshing then show headerView else hide headerView
        headerPadding = refreshControl.isRefreshing ? 0 : -max(rowHeight, bounds.height)
        
        //10. record current progress for next pulling
        headerPreviousProgress = refreshControl.progress
        //11. update current refresh control
        headerRefreshControl = refreshControl
    }
    
    func updateFooterRefreshControl(proxy: GeometryProxy, footerAnchor: FooterAnchorPreferenceKey.Value) {
        //1. guard footer view showing
        guard let footerView = footerAnchor.first else {
            return
        }
        
        //2. guard header view is not refreshing
        guard headerRefreshControl.progress == 0 else {
            return
        }
        
        //3. get footer view bounds
        let bounds = proxy[footerView.bounds]
        
        //4. temp footerRefreshControl to record property changed
        var refreshControl = footerRefreshControl
        
        //5. no content height
        if bounds.minY <= rowHeight || bounds.minY <= bounds.height {
            refreshControl.isRefreshing = false
        } else if refreshControl.isRefreshing && !footerView.isRefreshing {
            //6. outer not need to refresh
            refreshControl.isRefreshing = false
        } else {
            //7. visible content height - footer bounds origin y --> footerView begin visibling
            refreshControl.isRefreshing = proxy.size.height - bounds.minY + footerView.thresholdOffset > 0
        }
        
        //8. if not refresh the trigger the refresh
        if refreshControl.isRefreshing, !footerRefreshControl.isRefreshing {
            //9. refresh frequency is too high
            if let date = footerPreviousRefreshAt, Date().timeIntervalSince(date) < 0.1 {
                refreshControl.isRefreshing = false
            }
            footerPreviousRefreshAt = Date()
        }
        
        //10. update footerRefreshControl
        footerRefreshControl = refreshControl
    }
}
