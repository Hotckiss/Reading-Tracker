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
import SDWebImage
import FirebaseUI

final class FirebaseStorageManager {
    
    public static let DBManager = FirebaseStorageManager()
    private let rootReference = Storage.storage().reference()
    
    public func uploadCover(cover: UIImage, bookId: String, completion: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid,
              let data = cover.resizeImage(targetSize: CGSize(width: 310, height: 444)).pngData() else {
            return
        }
        
        let imageRef = rootReference.child("covers/\(uid)/\(bookId)/cover.png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        let uploadTask = imageRef.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                print("Error uploading image: \(error)")
                return
            }
            completion?()
        }
    }
    
    public func downloadCover(into imageView: UIImageView, bookId: String, onImageReceived: ((UIImage) -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {
                return
        }
        
        let imageRef = rootReference.child("covers/\(uid)/\(bookId)/cover.png")
        imageView.sd_setImage(with: imageRef, placeholderImage: UIImage(named: "bookPlaceholder")!) { (image, error, cacheType, storageReference) in
            onImageReceived?(image ?? UIImage(named: "bookPlaceholder")!)
        }
    }
}
