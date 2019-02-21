//
//  PlistManager.swift
//  Vezu
//
//  Created by Пользователь on 30.01.2019.
//  Copyright © 2019 VezuAppDevTeam. All rights reserved.
//

import Foundation

protocol PlistManagerEntityProtocol: Decodable {
    static var filename: String    { get }
}

class PlistManager {
    
    class func parse<T: PlistManagerEntityProtocol>() -> T {
        let url = Bundle.main.url(forResource: T.filename, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try! decoder.decode(T.self, from: data)
        
    }
    
}
