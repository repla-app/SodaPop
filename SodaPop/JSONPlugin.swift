//
//  JSONPlugin.swift
//  SodaPop
//
//  Created by Roben Kleene on 11/13/20.
//  Copyright © 2020 Roben Kleene. All rights reserved.
//

import Cocoa

enum JSONPluginLoadError: Error {
    case missingConfiguration(path: String)
}

class JSONPlugin: Plugin {
    class func validPlugin(path: String, pluginKind: PluginKind) throws -> Plugin? {
        do {
            throw JSONPluginLoadError.missingConfiguration(path: path)
        } catch let error as NSError {
            throw error
        }

//        return nil
    }
}
