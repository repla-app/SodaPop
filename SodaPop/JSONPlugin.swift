//
//  JSONPlugin.swift
//  SodaPop
//
//  Created by Roben Kleene on 11/13/20.
//  Copyright © 2020 Roben Kleene. All rights reserved.
//

import Cocoa
import StringPlusPath

enum JSONPluginLoadError: Error {
    case loadPluginInfoFailed(path: String, underlyingError: NSError?)
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

    static func load(from path: String) throws -> PluginInfo {
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(PluginInfo.self, from: data)
        } catch let error as NSError {
            throw JSONPluginLoadError.loadPluginInfoFailed(path: path, underlyingError: error)
        } catch {
            throw JSONPluginLoadError.loadPluginInfoFailed(path: path, underlyingError: nil)
        }

    }

    static func load(from url: URL) throws -> PluginInfo {
        return try load(from: url.path)
    }
}

class JSONPlugin: Plugin {
    class func validPlugin(path: String, pluginKind: PluginKind) throws -> Plugin? {
        do {
            let infoPath = path.appendingPathComponent(infoPathComponent)
            let pluginInfo = try PluginInfo.load(from: infoPath)
            return JSONPlugin(pluginInfo: pluginInfo, pluginKind: pluginKind, path: path)
        } catch let error as NSError {
            throw error
        }
    }

    convenience init(pluginInfo: PluginInfo, pluginKind: PluginKind, path: String) {
        self.init(pluginInfo: pluginInfo, pluginKind: pluginKind, fileURL: URL(fileURLWithPath: path))
    }
    
    init(pluginInfo: PluginInfo, pluginKind: PluginKind, fileURL: URL) {
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
