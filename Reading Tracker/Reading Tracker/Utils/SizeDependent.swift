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
    
    func convertSize(_ size: CGSize, persentage: CGFloat) -> CGSize {
        let wpers = size.width / UIScreen.main.bounds.width
        let hpers = size.height / UIScreen.main.bounds.width
        let currentPers = max(wpers, hpers)
        let scale = persentage / (currentPers * 100.0)
        
        if size.width == size.height {
            let squared = size.width * scale
            return CGSize(width: squared, height: squared)
        }
        
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    func scale(_ size: CGSize, persentage: CGFloat) -> CGFloat {
        let wpers = size.width / UIScreen.main.bounds.width
        let hpers = size.height / UIScreen.main.bounds.width
        let currentPers = max(wpers, hpers)
        let scale = persentage / (currentPers * 100.0)
        
        return scale
    }
    
    func scale(_ dimen: CGFloat, persentage: CGFloat) -> CGFloat {
        let wpers = dimen / UIScreen.main.bounds.width
        let hpers = dimen / UIScreen.main.bounds.width
        let currentPers = max(wpers, hpers)
        let scale = persentage / (currentPers * 100.0)
        
        return scale
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
    
    func convertDimension(_ val: CGFloat) -> CGFloat {
        switch UIScreen.main.bounds.width {
        case 320:
            return val * 0.8
        case 375:
            return val
        case 414:
            return val
        default:
            return val
        }
    }

    func convertFont(_ fontSize: CGFloat) -> CGFloat {
        switch UIScreen.main.bounds.width {
        case 320:
            return CGFloat(fontSize * 0.8 + 1)
        case 375:
            return fontSize
        case 414:
            return fontSize
        default:
            return fontSize
        }
    }
}
