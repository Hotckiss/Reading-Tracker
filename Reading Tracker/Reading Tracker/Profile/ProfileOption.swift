//
//  ProfileOption.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 1/19/19.
//  Copyright © 2019 Andrei Kirilenko. All rights reserved.
//

import Foundation

public struct ProfileOption {
    public let title: String
    public let subtitle: String
    
    public init(title: String,
                subtitle: String = "") {
        self.title = title
        self.subtitle = subtitle
    }
}
