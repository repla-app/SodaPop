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

struct PluginInfo: Codable {
    let name: String
    let command: String
    let uuid: String
    let editoable: Bool
    let fileExtensions: [String]?
    let debugEnabled: Bool?
    let autoShowLog: Bool?
    let transparentBackground: Bool?
    let usesEnvironment: Bool?
    let promptInterrupt: Bool?
}

class JSONPlugin: Plugin {
    class func validPlugin(path: String, pluginKind _: PluginKind) throws -> Plugin? {
        do {
            throw JSONPluginLoadError.missingConfiguration(path: path)
        } catch let error as NSError {
            throw error
        }

//        return nil
    }

//    init(pluginInfo: PluginInfo) {
//
//    }
}
