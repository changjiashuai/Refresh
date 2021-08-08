//
//  HeaderAnchorPrefenceKey.swift
//  
//
//  Created by CJS on 2021/8/8.
//

import SwiftUI

@available(iOS 13.0, *)
struct HeaderAnchorPrefenceKey: PreferenceKey {
    
    typealias Value = [HeaderView]
    
    static var defaultValue: Value = []
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
    @available(iOS 13.0, *)
    struct HeaderView {
        let bounds: Anchor<CGRect>
        let isRefreshing: Bool
    }
    
}
