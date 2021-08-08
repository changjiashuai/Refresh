//
//  FooterAnchorPreferenceKey.swift
//  
//
//  Created by CJS on 2021/8/8.
//

import SwiftUI

@available(iOS 13.0, *)
struct FooterAnchorPreferenceKey: PreferenceKey {
    typealias Value = [FooterView]
    
    static var defaultValue: [FooterView] = []
    
    static func reduce(value: inout [FooterView], nextValue: () -> [FooterView]) {
        value.append(contentsOf: nextValue())
    }
    
    @available(iOS 13.0, *)
    struct FooterView {
        let bounds: Anchor<CGRect>
        let thresholdOffset: CGFloat
        let isRefreshing: Bool
    }
}
