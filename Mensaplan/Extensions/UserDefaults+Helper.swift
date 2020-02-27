//
//  UserDefaults+Helper.swift
//  myTodo
//
//  Created by Marc Hein on 05.06.19.
//  Copyright © 2019 Marc Hein Webdesign. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func hasValue(forKey key: String) -> Bool {
        return nil != object(forKey: key)
    }
    
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
