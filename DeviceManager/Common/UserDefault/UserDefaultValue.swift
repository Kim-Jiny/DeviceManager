//
//  UserDefaultValue.swift
//  DeviceManager
//
//  Created by 김미진 on 11/25/23.
//

import Foundation
@propertyWrapper
struct UserDefaultValue<Value: Codable> {

    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            let data = UserDefaults.standard.data(forKey: key)
            let value = data.flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
