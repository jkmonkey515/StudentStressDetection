//
//  UserDefaults_Helper.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/28/24.
//

import Foundation

extension UserDefaults.Key {
    static let user = UserDefaults.Key("user")
    static let authCompleted = UserDefaults.Key("authCompleted")
}

final class UserData {
    static let shared = UserData()
    let defaults = UserDefaults.standard
    
    func setAuthStatus(_ value: Bool) {
        defaults.set(value, key: .authCompleted)
    }
    func authFinished() -> Bool {
        defaults.getBool(key: .authCompleted)
    }
    func setUser(_ user: AppUser) {
        let encoder = JSONEncoder()
        if let encodedUser = try? encoder.encode(user) {
            defaults.set(encodedUser, key: .user)
        }
    }
    func getUser() -> AppUser {
        let user = AppUser.default
        guard let saved = defaults.getObject(key: .user) as? Data else { return user }
        let decoder = JSONDecoder()
        if let me = try? decoder.decode(AppUser.self, from: saved) {
            return me
        }
        return user
    }
    
    func clearUserData() {
        defaults.clearUserDefaults()
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    struct Key {
        fileprivate let name: String
        public init(_ name: String) {
            self.name = name
        }
    }
    
    func set(_ value: Any?, key: Key) {
        set(value, forKey: key.name)
        synchronize()
    }
    
    func getString(key: Key) -> String {
        return string(forKey: key.name) ?? ""
    }
    func getBool(key: Key) -> Bool {
        return bool(forKey: key.name)
    }
    func getObject(key: Key) -> Any? {
        return object(forKey: key.name)
    }
    
    func keyExits(key: Key) -> Bool {
        return object(forKey: key.name) != nil
    }
    func removeValue(key: Key) {
        DispatchQueue.main.async { [self] in
            removeObject(forKey: key.name)
            synchronize()
        }
    }
    func clearUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            print("UserDefaults cleared for \(bundleID)")
        }
    }
}
