//
//  Extension+Color.swift
//  DeviceManager
//
//  Created by 김미진 on 11/25/23.
//

import SwiftUI

extension Color {
    // Hex 코드로 컬러치환
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    static func myColor(lightMode: Color, darkMode: Color) -> Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return darkMode
        } else {
            return lightMode
        }
    }
}
