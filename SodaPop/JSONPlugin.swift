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
    let editable: Bool
    let hidden: Bool?
    let fileExtensions: [String]?
    let debugEnabled: Bool?
    let autoShowLog: Bool?
    let transparentBackground: Bool?
    let usesEnvironment: Bool?
    let promptInterrupt: Bool?

    static func load(from url: URL) throws -> PluginInfo {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(PluginInfo.self, from: data)
    }
}

class JSONPlugin: Plugin {
    class func validPlugin(path: String, pluginKind _: PluginKind) throws -> Plugin? {
        do {
            throw JSONPluginLoadError.missingConfiguration(path: path)
        } catch let error as NSError {
            throw error
        }
    }

    init(pluginInfo: PluginInfo, fileURL: URL, pluginKind: PluginKind) {
        super.init(autoShowLog: pluginInfo.autoShowLog,
                   debugModeEnabled: pluginInfo.debugEnabled,
                   hidden: pluginInfo.hidden ?? defaultPluginHidden,
                   promptInterrupt: pluginInfo.promptInterrupt ?? defaultPluginPromptInterrupt,
                   transparentBackground: pluginInfo.transparentBackground ?? defaultPluginTransparentBackground,
                   usesEnvironment: pluginInfo.usesEnvironment ?? defaultPluginUsesEnvironment,
                   path: fileURL.path,
                   url: fileURL,
                   resourcePath: fileURL.path,
                   kind: pluginKind,
                   resourceURL: fileURL,
                   editable: pluginInfo.editable,
                   command: pluginInfo.command,
                   identifier: pluginInfo.uuid,
                   name: pluginInfo.name,
                   suffixes: nil)
    }
}
