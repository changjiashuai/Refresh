//
//  EnvironmentValues+Extension.swift
//  
//
//  Created by CJS on 2021/8/8.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
extension EnvironmentValues {
    
    var headerRefreshControl: HeaderControlEnvironmentKey.HeaderRefreshControl {
        get { self[HeaderControlEnvironmentKey.self] }
        set { self[HeaderControlEnvironmentKey.self] = newValue }
    }
    
    var footerRefreshControl: FooterControlEnvironmentKey.FooterRefreshControl {
        get { self[FooterControlEnvironmentKey.self] }
        set { self[FooterControlEnvironmentKey.self] = newValue }
    }
}

struct HeaderControlEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: HeaderRefreshControl = .init(isEnabled: false)
    
    struct HeaderRefreshControl {
        let isEnabled: Bool
        var progress: CGFloat = 0
        var isRefreshing: Bool = false
    }
}

struct FooterControlEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: FooterRefreshControl = .init(isEnabled: false)
    
    struct FooterRefreshControl {
        let isEnabled: Bool
        var isRefreshing: Bool = false
    }
}
