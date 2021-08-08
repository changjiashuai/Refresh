//
//  ScrollView+Extension.swift
//  
//
//  Created by CJS on 2021/8/8.
//

import SwiftUI

@available(iOS 13.0, *)
extension ScrollView {
    
    public func enableRefresh(_ enable: Bool = true) -> some View {
        modifier(RefreshModifier(enable: enable))
    }
}

