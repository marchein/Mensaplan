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
    
}
