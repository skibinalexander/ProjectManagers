//
//  LogManager.swift
//  Vezu
//
//  Created by Пользователь on 01.02.2019.
//  Copyright © 2019 VezuAppDevTeam. All rights reserved.
//

import Foundation
import SwiftyBeaver

protocol LogManagerSerializeObjectDataProtocol {
    func loggerDebug()      -> String
    func loggerInfo()       -> String
    func loggerWarning()    -> String
}

extension LogManagerSerializeObjectDataProtocol {
    
    //  Need override methods
    
    func loggerDebug()      -> String {
        return ""
    }
    
    func loggerInfo()       -> String {
        return ""
    }
    
    func loggerWarning()    -> String {
        return ""
    }
    
}

class LogManager {
    
    static let shared: LogManager = LogManager()
    
    let logger = SwiftyBeaver.self
    
    init() {
        installBeaver()
    }
    
    private func installBeaver() {
        
        let console     = ConsoleDestination()  // log to Xcode Console
        let file        = FileDestination()  // log to default swiftybeaver.log file
        let cloud       = SBPlatformDestination(appID: "36rAMN", appSecret: "Pbi94ceazvlpsphcvfdwcRhemglc3ekb", encryptionKey: "Pbi94ceazvlpsphcvfdwcRhemglc3ekb")
        
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        // or use this for JSON output: console.format = "$J"
        
        // add the destinations to SwiftyBeaver
        logger.addDestination(console)
        logger.addDestination(file)
        logger.addDestination(cloud)
        
        //        // Now let’s log!
        //        logger.verbose("not so important")  // prio 1, VERBOSE in silver
        //        logger.debug("something to debug")  // prio 2, DEBUG in green
        //        logger.info("a nice information")   // prio 3, INFO in blue
        //        logger.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        //        logger.error("ouch, an error did occur!")  // prio 5, ERROR in red
        //
        //        // log anything!
        //        logger.verbose(123)
        //        logger.info(-123.45678)
        //        logger.warning(Date())
        //        logger.error(["I", "like", "logs!"])
        //        logger.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
        //
        //        // optionally add context to a log message
        //        console.format = "$L: $M $X"
        //        logger.debug("age", "123")  // "DEBUG: age 123"
        //        logger.info("my data", context: [1, "a", 2]) // "INFO: my data [1, \"a\", 2]"
        
    }
    
}
