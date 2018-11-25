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
import RxSwift

final class FirestoreManager {
    private enum Consts {
        static let genderKey = "gender"
        static let degreeKey = "degree"
        static let occupationKey = "occupation"
        static let firstNameKey = "firstName"
        static let majorKey = "major"
        static let favoriteBookFormatKey = "favorite book format"
        static let favoriteAuthorsKey = "favorite authors"
        static let lastNameKey = "lastName"
        static let favoriteBooksKey = "favorite books"
    }
    
    public static let DBManager = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    public func registerUser(user: UserModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(uid).setData([
            "firstName": user.firstName,
            "lastName": user.lastName,
            "gender": (user.gender ? "Ж" : "М"),
            "degree": user.degree,
            "major": user.major,
            "occupation": user.occupation,
            "favorite books": user.favoriteBooks,
            "favorite authors": user.favoriteAuthors,
            "favorite book format": user.favoriteFormat,
            ], merge: true) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    public func updateQuestionarre(q: Questionarrie, onError: ((String) -> Void)?, onCompleted: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("questionarries").document(uid).setData([
            "firstName": q.firstName,
            "lastName": q.lastName,
            "sex": q.sex.rawValue,
            "degree": q.education.rawValue,
            "major": q.major,
            "occupation": q.workSphere,
            "favorite books": q.favoriteBooks,
            "favorite authors": q.favoriteAuthors,
            "favorite book format": q.bookType.rawValue,
            ]) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                    onError?("\(error)")
                } else {
                    print("Document successfully written!")
                    onCompleted?()
                }
        }
    }
    
    public func downloadQuestionarrie(onCompleted: ((Questionarrie) -> Void)?, onError: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("questionarries").document(uid).getDocument { (document, error) in
            if let document = document,
                let data = document.data(),
                document.exists {
                var q = Questionarrie()
                for (key, value) in data {
                    guard let stringValue = value as? String else {
                        print("Document error format")
                        return
                    }
                    switch key {
                    case "sex":
                        q.sex = Sex(str: stringValue)
                    case "degree":
                        q.education = Education(str: stringValue)
                    case "occupation":
                        q.workSphere = stringValue
                    case "firstName":
                        q.firstName = stringValue
                    case "major":
                        q.major = stringValue
                    case "favorite book format":
                        q.bookType = BookType.generate(raw: stringValue)
                    case "favorite authors":
                        q.favoriteAuthors = stringValue
                    case "lastName":
                        q.lastName = stringValue
                    case "favorite books":
                        q.favoriteBooks = stringValue
                    default:
                        break
                    }
                }
                onCompleted?(q)
            } else {
                print("Document does not exist")
                onError?()
            }
        }
    }
    
    public func loadUserProfile() -> Observable<UserModel> {
        guard let uid = Auth.auth().currentUser?.uid else {
            return .empty()
        }
        
        let resultSubject = PublishSubject<UserModel>()
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document,
               let data = document.data(),
               document.exists {
                var user = UserModel()
                for (key, value) in data {
                    guard let stringValue = value as? String else {
                        print("Document error format")
                        return
                    }
                    switch key {
                    case Consts.genderKey:
                        user.gender = (stringValue == "M" ? false : true)
                    case Consts.degreeKey:
                        user.degree = stringValue
                    case Consts.occupationKey:
                        user.occupation = stringValue
                    case Consts.firstNameKey:
                        user.firstName = stringValue
                    case Consts.majorKey:
                        user.major = stringValue
                    case Consts.favoriteBookFormatKey:
                        user.favoriteFormat = stringValue
                    case Consts.favoriteAuthorsKey:
                        user.favoriteAuthors = stringValue
                    case Consts.lastNameKey:
                        user.lastName = stringValue
                    case Consts.favoriteBooksKey:
                        user.favoriteBooks = stringValue
                    default:
                        break
                    }
                }
                
                resultSubject.onNext(user)
            } else {
                //todo: no user
                resultSubject.onNext(UserModel())
                print("Document does not exist")
                
            }
        }
        
        return resultSubject.asObservable()
    }
    
    public func addBook(book: BookModel, completion: ((String) -> Void)?) -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let ref = db.collection("books")
            .document("libraries")
            .collection(uid)
            .addDocument(data: [
            "title": book.title,
            "author": book.author,
            "last updated": formatter.string(from: book.lastUpdated),
            "type": book.type.rawValue
            ]) { error in
                if let error = error {
                    print("Error writing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully written!")
                }
        }
        
        completion?(ref.documentID)
        return ref.documentID
    }
    
    public func getAllBooks(completion: (([BookModel]) -> Void)? = nil, onError: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("books")
            .document("libraries")
            .collection(uid)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var res: [BookModel] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let id = document.documentID
                        var book = BookModel()
                        book.id = id
                        for (key, value) in data {
                            guard let stringValue = value as? String else {
                                print("Document error format")
                                return
                            }
                            switch key {
                            case "author":
                                book.author = stringValue
                            case "last updated":
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                book.lastUpdated = formatter.date(from: stringValue)!
                            case "title":
                                book.title = stringValue
                            case "type":
                                book.type = BookType.generate(raw: stringValue)
                            default:
                                break
                            }
                        }
                        
                        res.append(book)
                    }
                    completion?(res)
                }
        }
    }
    
    public func updateBook(book: BookModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        db.collection("books")
            .document("libraries")
            .collection(uid)
            .document(book.id)
            .setData([
                "title": book.title,
                "author": book.author,
                "last updated": formatter.string(from: book.lastUpdated),
                "type": book.type.rawValue
            ], merge: true) { error in
                if let error = error {
                    print("Error writing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully written!")
                }
        }
    }
    
    //TODO remove cover
    public func removeBook(book: BookModel, onSuccess: (() -> Void)? = nil, onError: (() -> Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("books")
            .document("libraries")
            .collection(uid)
            .document(book.id)
            .delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                    onError?()
                } else {
                    onSuccess?()
                    print("Document successfully removed!")
                }
        }
    }
    
    
    func downloadOZONBook(ozonId: String, onSuccess: ((BookModel, String) -> Void)?, onFail: (() -> Void)?) {
        db.collection("ozon_catalog")
            .document(ozonId)
            .getDocument { (document, error) in
                if let document = document,
                    let data = document.data(),
                    document.exists {
                    var book = BookModel()
                    var url = ""
                    for (key, value) in data {
                        guard let stringValue = value as? String else {
                            print("Document error format")
                            return
                        }
                        switch key {
                        case "name":
                            book.title = stringValue
                        case "author":
                            book.author = stringValue
                        case "coverURL":
                            url = stringValue
                            break
                        case "icbn":
                            break
                        default:
                            break
                        }
                    }
                    onSuccess?(book, url)
                } else {
                    onFail?()
                }
        }
    }
    
    public func uploadSession(session: SessionFinishModel, completion: (() -> Void)?, onError: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("sessions")
            .document("sessions_list")
            .collection(uid)
            .addDocument(data: [
                "book id": session.bookInfo.id,
                "start page": session.startPage,
                "last page": session.finishPage,
                "time": session.time,
                "mood": session.mood.rawValue,
                "place": session.readPlace.rawValue,
                "comment": session.comment,
            ]) { error in
                if let error = error {
                    print("Error writing document: \(error.localizedDescription)")
                    onError?()
                } else {
                    print("Document successfully written!")
                    completion?()
                }
        }
    }
    
    func uploadOZONCatalog(books: [OZONBook]) {
        print("Starting upload...")
        var progress = 0
        var errorsCount = 0
        let total = books.count
        
        for book in books {
            db.collection("ozon_catalog")
                .document(book.barcode)
                .setData([
                    "icbn": book.barcode,
                    "name": book.name,
                    "author": book.author,
                    "coverURL": book.coverURL
                ], merge: true) { error in
                    if error != nil {
                        errorsCount += 1
                    }
                    progress += 1
                    
                    print("Progress: \(progress)/\(total), Errors count: \(errorsCount)")
            }
        }
    }
}
