//
//  RootScreenManager.swift
//  Vezu
//
//  Created by Пользователь on 13/02/2019.
//  Copyright © 2019 VezuAppDevTeam. All rights reserved.
//

import Foundation

enum RootScreenManagerType {
    case onStart
    case onBoard
    case onMain
}

class RootScreenManager {
    
    static func rootType() -> RootScreenManagerType {
        return .onStart
    }
    
}
