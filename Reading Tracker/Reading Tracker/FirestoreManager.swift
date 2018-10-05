//
//  FirestoreManager.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 05.10.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

final class FirestoreManager {
    public static let DBManager = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {
    }
    
    public func registerUser(user: UserModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(uid).setData([
            "gender": user.gender,
            "degree": user.degree,
            "major": user.major,
            "occupation": user.occupation,
            "favorite books and authors": user.favouriteBooks,
            "favorite book format": user.favouriteFormat,
            ], merge: true) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
