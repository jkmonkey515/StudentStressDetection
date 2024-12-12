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
    let usersCollectionName = "users"
    let dailyFeelingCollectionName = "daily_feelings"
    
    let refUsers = Firestore.firestore().collection("users")
    let refDailyFeelings = Firestore.firestore().collection("daily_feelings")
    
    // MARK: - User
    func createUser(uid: String, name: String, photo: String) {
        db.collection(usersCollectionName).document("user_\(uid)").setData([
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
                try await refUsers.document("user_\(user.uid)").updateData([
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
                let doc = try await refUsers.document("user_\(uid)").getDocument()
                return try doc.data(as: UserModel.self)
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func checkUserExist(uid: String) async -> Bool {
        let docRef = refUsers.document("user_\(uid)")
        do {
            return try await docRef.getDocument().exists
        } catch {
            return false
        }
    }
    
    // MARK: - Delete User account from Firebase Auth
    func deleteUser() async {
        let uid = UserData.shared.getUser().uid
        do {
            // delete user data
            try await refUsers.document("user_\(uid)").delete()
            // delete user tips
            let list = try await db.collection("tips")
                .whereField("uid", isEqualTo: uid)
                .getDocuments().documents
            for doc in list {
                try await refUsers.document(doc.documentID).delete()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Submit Daily Feelings
    // level: 1-5 (saddest - happiest)
    func submitDailyFeelings(level: Int, note: String, levelByAI: Int?) {
        let uid = UserData.shared.getUser().uid
        let newDoc = refDailyFeelings.document()
        newDoc.setData([
            "docId": newDoc.documentID,
            "uid": uid,
            "level": level, // user input stree level
            "note": note,
            "levelByAI": levelByAI ?? 0,
            "createdAt": Date()
        ])
    }
    
    func addListenerOnDailyFeelings(completion: @escaping (_ data: [DailyFeelingModel]) -> Void) {
        let uid = UserData.shared.getUser().uid
        refDailyFeelings.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching document: \(error!)")
                return
            }
            let listData = documents.compactMap { snap -> DailyFeelingModel? in
                do {
                    let one = try snap.data(as: DailyFeelingModel.self)
                    if one.uid == uid {
                        return one
                    } else {
                        return nil
                    }
                } catch {
                    return nil
                }
            }
            let result = listData.sorted { item1, item2 in
                item1.createdAt > item2.createdAt
            }
            completion(result)
        }
    }
    
    // to fetch all data list of "daily_feelings"
    func fetchDailyFeelingsData(_ type: StatsDateType = .weekly) async -> [DailyFeelingModel] {
        let startDate = Date().startOfMonth()
        let endDate = Date().endOfMonth()
        let uid = UserData.shared.getUser().uid
        do {
            let list = try await refDailyFeelings
                .whereField("uid", isEqualTo: uid)
                .whereField("createdAt", isGreaterThan: startDate)
                .whereField("createdAt", isLessThan: endDate)
                .order(by: "createdAt", descending: true)
                .getDocuments().documents
            return list.compactMap { snap -> DailyFeelingModel? in
                do {
                    return try snap.data(as: DailyFeelingModel.self)
                } catch {
                    return nil
                }
            }
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    // MARK: - remove
    func removeTip(_ item: DailyFeelingModel) async {
        do {
            try await db.collection(dailyFeelingCollectionName).document(item.docId).delete()
        } catch {
            print(error.localizedDescription)
        }
    }

    
    
    
}

