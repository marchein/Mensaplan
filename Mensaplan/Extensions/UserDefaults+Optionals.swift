//
//  UserDefaults+Optionals.swift
//  Mensaplan
//
//  Created by Marc Hein on 27.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import Foundation

extension UserDefaults {

    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }

    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}
