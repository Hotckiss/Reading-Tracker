//
//  SizeDependent.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 26/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

enum Size {
    case small
    case medium
    case big
}

final class SizeDependent {
    static let instance = SizeDependent()
    private let W = 360
    private let H = 700
    
    func getSize() -> Size {
        switch UIScreen.main.bounds.width {
        case 320:
            return .small
        case 375:
            return .medium
        case 414:
            return .big
        default:
            return .big
        }
    }
    
    func convertSize(_ size: CGSize) -> CGSize {
        switch UIScreen.main.bounds.width {
        case 320:
            return CGSize(width: size.width * 0.8, height: size.height * 0.8)
        case 375:
            return size
        case 414:
            return size
        default:
            return size
        }
    }
    
    func convertPadding(_ padding: CGFloat) -> CGFloat {
        switch UIScreen.main.bounds.width {
        case 320:
            return padding * 0.8
        case 375:
            return padding
        case 414:
            return padding
        default:
            return padding
        }
    }
    
    func convertFont(_ fontSize: Int) -> Int {
        switch UIScreen.main.bounds.width {
        case 320:
            return Int(Double(fontSize) * 0.8 + 1)
        case 375:
            return fontSize
        case 414:
            return fontSize
        default:
            return fontSize
        }
    }
}
