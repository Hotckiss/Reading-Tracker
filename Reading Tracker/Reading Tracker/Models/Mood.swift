//
//  Mood.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 11/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public enum Mood: String {
    case verySad = "very sad"
    case sad = "sad"
    case neutral = "neutral"
    case happy = "happy"
    case veryHappy = "very happy"
    case unknown = "unknown"
    
    init(ind: Int?) {
        if let ind = ind {
            switch ind {
            case 0:
                self = .verySad
            case 1:
                self = .sad
            case 2:
                self = .neutral
            case 3:
                self = .happy
            case 4:
                self = .veryHappy
            default:
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    init(str: String) {
        switch str {
        case "very happy":
            self = .veryHappy
        case "happy":
            self = .happy
        case "neutral":
            self = .neutral
        case "sad":
            self = .sad
        case "very sad":
            self = .verySad
        default:
            self = .unknown
        }
    }
    
    public static let all: [Mood] = [.verySad, .sad, .neutral, .happy, .veryHappy]
}
