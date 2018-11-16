//
//  FirebaseStorageManager.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 16/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

final class FirebaseStorageManager {
    
    public static let DBManager = FirebaseStorageManager()
    private let rootReference = Storage.storage().reference()
    
    public func uploadCover(cover: UIImage, bookId: String, completion: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid,
              let data = cover.pngData() else {
            return
        }
        
        let imageRef = rootReference.child("covers/\(uid)/\(bookId)/cover.png")
        
        let uploadTask = imageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("Error uploading image: \(error)")
                return
            }
            completion?()
            /*
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            rootReference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }*/
        }
    }
}
