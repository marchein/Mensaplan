//
//  WatchMessage.swift
//  Mensaplan
//
//  Created by Marc Hein on 25.02.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import Foundation
import WatchSync

struct WatchMessage: SyncableMessage {
    var selectedPrice: String?
    var selectedMensa: String?
    var lastUpdate: String?
    var jsonData: Data?
}
