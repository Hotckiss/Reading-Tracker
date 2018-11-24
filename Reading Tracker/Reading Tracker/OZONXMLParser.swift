//
//  OZONXMLParser.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 24/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import SwiftyXMLParser

struct OZONBook {
    var author: String
    var name: String
    var barcode: String
    var coverURL: String
}

final class OZONXMLParser {
    var booksList: [OZONBook] = []
    
    func deployCatalog() {
        print("Fetching catalog...")
        guard let path = Bundle.main.path(forResource: "catalog", ofType: "xml") else {
            print("Catalog not found!")
            return
        }
        
        do {
            print("Fetching catalog data...")
            let contents = try String(contentsOfFile: path)
            print("Parse XML file...")
            let xml = try! XML.parse(contents)
            
            let offers = xml["yml_catalog", "shop", "offers", "offer"]
            
            print("Collecting books data...")
            for offer in offers {
                let name = offer["name"].text
                let author = offer["author"].text
                let barcode = offer["barcode"].text
                let coverURL = offer["picture"][0].text
                
                if let name = name,
                    let barcode = barcode,
                    let coverURL = coverURL {
                    booksList.append(OZONBook(author: author ?? "", name: name, barcode: barcode, coverURL: coverURL))
                }
            }
            
            print("Total books collected: \(booksList.count)")
            FirestoreManager.DBManager.uploadOZONCatalog(books: booksList)
        }
        catch {
            print("Parsing completed wirh errors!")
        }
    }
}
