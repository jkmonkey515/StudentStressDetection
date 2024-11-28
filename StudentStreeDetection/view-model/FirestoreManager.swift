//
//  FirestoreManager.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/28/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    init() {}
    
    let db = Firestore.firestore()
    
    // MARK: - User
    func createUser(uid: String, name: String, photo: String) {
        db.collection("users").document("user_\(uid)").setData([
            "uid": uid,
            "name": name,
            "photo": photo,
            "hasMembership": false
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                //                print("Manager Data successfully written!")
            }
        }
    }
    func updateUser(user: AppUser, newName: String, profileUrl: String) async -> Bool {
        if await checkUserExist(uid: user.uid) {
            do {
                try await db.collection("users").document("user_\(user.uid)").updateData([
                    "name": newName,
                    "photo": profileUrl
                ])
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            createUser(uid: user.uid, name: newName, photo: profileUrl)
            return true
        }
    }
    
    func fetchUser(uid: String) async -> UserModel? {
        do {
            if await checkUserExist(uid: uid) {
                let doc = try await db.collection("users").document("user_\(uid)").getDocument()
                return try doc.data(as: UserModel.self)
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func checkUserExist(uid: String) async -> Bool {
        let docRef = db.collection("users").document("user_\(uid)")
        do {
            return try await docRef.getDocument().exists
        } catch {
            return false
        }
    }
    
    // MARK: - Delete User account from Firebase Auth
    func deleteData() async {
        let uid = UserData.shared.getUser().uid
        do {
            // delete user data
            try await db.collection("users").document("user_\(uid)").delete()
            // delete user tips
            let list = try await db.collection("tips")
                .whereField("uid", isEqualTo: uid)
                .getDocuments().documents
            for doc in list {
                try await db.collection("tips").document(doc.documentID).delete()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Tip
    func submitTip(tip: Double, type: String, note: String) {
        let uid = UserData.shared.getUser().uid
        let newTipDoc = db.collection("tips").document()
        newTipDoc.setData([
            "docId": newTipDoc.documentID,
            "uid": uid,
            "tip": tip,
            "type": type, // cash, card
            "note": note,
            "createdAt": Date()
        ])
        
        print("Testing ID: ", newTipDoc.documentID)
    }

    
    
    
}

