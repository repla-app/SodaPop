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

enum JSONPluginWriteError: Error {
    case failedToWriteInfoError(url: URL, underlyingError: NSError?)
}

struct PluginInfo: Codable {
    var name: String
    var command: String?
    var uuid: String
    var editable: Bool?
    var hidden: Bool?
    var fileExtensions: [String]?
    var debugModeEnabled: Bool?
    var autoShowLog: Bool?
    var transparentBackground: Bool?
    var usesEnvironment: Bool?
    var promptInterrupt: Bool?

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
    
    func write(to url: URL) throws {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            try data.write(to: url)
        } catch let error as NSError {
            throw JSONPluginWriteError.failedToWriteInfoError(url: url, underlyingError: error)
        } catch {
            throw JSONPluginWriteError.failedToWriteInfoError(url: url, underlyingError: nil)
        }
    }
    
    static func load(from url: URL) throws -> PluginInfo {
        return try load(from: url.path)
    }
}

class JSONPlugin: Plugin {
    var pluginInfo: PluginInfo
    var infoPath: String {
        type(of: self).infoPath(fromPath: path)
    }
    var infoURL: URL {
        URL(fileURLWithPath: infoPath)
    }

    class func infoPath(fromPath path: String) -> String {
        path.appendingPathComponent(infoPathComponent)
    }

    class func validPlugin(path: String, pluginKind: PluginKind) throws -> JSONPlugin? {
        do {
            let pluginInfo = try PluginInfo.load(from: JSONPlugin.infoPath(fromPath: path))
            return JSONPlugin(pluginInfo: pluginInfo, pluginKind: pluginKind, path: path)
        } catch let error as NSError {
            throw error
        } catch {
            throw JSONPluginLoadError.loadPluginInfoFailed(path: path, underlyingError: nil)
        }
    }

    convenience init(pluginInfo: PluginInfo, pluginKind: PluginKind, path: String) {
        self.init(pluginInfo: pluginInfo, pluginKind: pluginKind, fileURL: URL(fileURLWithPath: path))
    }


    // This is used to configure the resource URL if a plugin has both a
    // `repla.json` an `Contents/Info.plist`, it primarily exists so that test
    // plugins can be loaded as either `JSONPlugin` or `XMLPlugin` and just
    // have one set of resources at `Contents/Resources`
    static func getResourceFileURL(for fileURL: URL) -> URL {
        guard FileManager.default.fileExists(atPath: fileURL.path.appendingPathComponent(infoDictionaryPathComponent)) else {
            return fileURL
        }
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: fileURL.path.appendingPathComponent(resourcePathComponent), isDirectory: &isDir) && isDir.boolValue else {
            return fileURL
        }
        return fileURL.appendingPathComponent(resourcePathComponent)
    }
    
    init(pluginInfo: PluginInfo, pluginKind: PluginKind, fileURL: URL) {
        let resourceURL = type(of: self).getResourceFileURL(for: fileURL)
        let resourcePath = resourceURL.path
        self.pluginInfo = pluginInfo
        super.init(autoShowLog: pluginInfo.autoShowLog,
                   debugModeEnabled: pluginInfo.debugModeEnabled,
                   hidden: pluginInfo.hidden ?? defaultPluginHidden,
                   promptInterrupt: pluginInfo.promptInterrupt ?? defaultPluginPromptInterrupt,
                   transparentBackground: pluginInfo.transparentBackground ?? defaultPluginTransparentBackground,
                   usesEnvironment: pluginInfo.usesEnvironment ?? defaultPluginUsesEnvironment,
                   path: fileURL.path,
                   url: fileURL,
                   resourcePath: resourcePath,
                   kind: pluginKind,
                   resourceURL: resourceURL,
                   editable: pluginInfo.editable ?? defaultPluginEditable,
                   command: pluginInfo.command,
                   identifier: pluginInfo.uuid,
                   name: pluginInfo.name,
                   suffixes: pluginInfo.fileExtensions)
    }

    // MARK: Properties

    override public dynamic var name: String {
        didSet {
            pluginInfo.name = name
            save()
        }
    }

    override public var identifier: String {
        didSet {
            pluginInfo.uuid = identifier
            save()
        }
    }

    override public dynamic var command: String? {
        didSet {
            pluginInfo.command = command
            save()
        }
    }

    override public dynamic var suffixes: [String]? {
        didSet {
            pluginInfo.fileExtensions = suffixes
            save()
        }
    }

    override public dynamic var editable: Bool {
        didSet {
            if !editable {
                pluginInfo.editable = editable
            } else {
                pluginInfo.editable = nil
            }
            save()
        }
    }

    // MARK: Save
    private func save() {
        assert(Thread.isMainThread)
        do {
            try pluginInfo.write(to: infoURL)
        } catch let JSONPluginWriteError.failedToWriteInfoError(url: url, underlyingError: error) {
            print("Faile to write info JSON at URL \(url), error \(error?.description ?? "nil").")
        } catch let error as NSError {
            print("Failed to write an info dictionary \(error)")
        }
    }
}
