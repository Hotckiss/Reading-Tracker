//
//  Mood.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public enum Mood: String {
    case sad = "sad"
    case neutral = "neutral"
    case happy = "happy"
    case unknown = "unknown"
    
    init(ind: Int?) {
        if let ind = ind {
            switch ind {
            case 0:
                self = .happy
            case 1:
                self = .neutral
            case 2:
                self = .sad
            default:
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    init(str: String) {
        switch str {
        case "happy":
            self = .happy
        case "neutral":
            self = .neutral
        case "sad":
            self = .sad
        default:
            self = .unknown
        }
    }
    
    public static let all: [Mood] = [.sad, .neutral, .happy]
}
