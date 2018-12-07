//
//  PluralRule.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 07/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation

public enum PluralCategory {
    case zero
    case one
    case two
    case few
    case many
    case other
}

public struct PluralRule {
    public func numToCategory(_ num: Int) -> PluralCategory {
        if num % 10 == 1, num % 100 != 11 {
            return .one
        } else if (2...4).contains(num % 10), (12...14).contains(num % 100) == false {
            return .few
        } else if num % 10 == 0 || (5...9).contains(num % 10) || (11...14).contains(num % 100) {
            return .many
        } else {
            return .other
        }
    }
    
    public func formatCardinal(_ num: Int, categoryToString: [PluralCategory: String]) -> String {
        let category = numToCategory(num)
        
        if let value = categoryToString[category] {
            return "\(num) \(value)"
        } else {
            return "\(num)"
        }
    }
    
    public func formatBooks(count: Int) -> String {
        return formatCardinal(
            count,
            categoryToString: [
                .one: "книга",
                .few: "книги",
                .many: "книг",
                .other: "книги"
            ]
        )
    }
    
    public func formatPages(count: Int) -> String {
        return formatCardinal(
            count,
            categoryToString: [
                .one: "страница",
                .few: "страницы",
                .many: "страниц",
                .other: "страницы"
            ]
        )
    }
    
    public func formatAttempts(count: Int) -> String {
        return formatCardinal(
            count,
            categoryToString: [
                .one: "подход",
                .few: "подхода",
                .many: "подходов",
                .other: "подхода"
            ]
        )
    }
    
    public func getAttempts(count: Int) -> String {
        let category = numToCategory(count)
        
        let categoryToString: [PluralCategory: String] = [
        .one: "подход",
        .few: "подхода",
        .many: "подходов",
        .other: "подхода"
        ]
        
        if let value = categoryToString[category] {
            return "\(value)"
        }
        
        return "подходов"
    }
}
