//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

@objcMembers
public class Plugin: POPPlugin {
    enum PluginWriteError: Error {
        case failToWriteDictionaryError(URL: URL)
    }

    struct ClassConstants {
        static let infoDictionaryPathComponent = "Contents".appendingPathComponent("Info.plist")
    }

    let bundle: Bundle
    let hidden: Bool
    public let promptInterrupt: Bool
    public let debugModeEnabled: Bool?
    public let autoShowLog: Bool?
    public let transparentBackground: Bool?
    let pluginType: PluginType

    init(bundle: Bundle,
         infoDictionary: [AnyHashable: Any],
         pluginType: PluginType,
         identifier: String,
         name: String,
         command: String?,
         suffixes: [String]?,
         hidden: Bool,
         editable: Bool,
         debugModeEnabled: Bool?,
         transparentBackground: Bool?,
         autoShowLog: Bool?,
         promptInterrupt: Bool?) {
        self.infoDictionary = infoDictionary
        self.pluginType = pluginType
        self.bundle = bundle
        self.name = name
        self.identifier = identifier
        self.hidden = hidden
        self.editable = editable

        // Optional
        self.command = command
        self.suffixes = [String]()
        if let suffixes = suffixes {
            self.suffixes += suffixes
        }
        self.debugModeEnabled = debugModeEnabled
        self.transparentBackground = debugModeEnabled
        self.autoShowLog = autoShowLog
        if let promptInterrupt = promptInterrupt {
            self.promptInterrupt = promptInterrupt
        } else {
            self.promptInterrupt = false
        }
    }

    // MARK: Paths

    public var resourcePath: String? {
        return bundle.resourcePath
    }

    public var resourceURL: URL? {
        if let path = resourcePath {
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    internal var infoDictionary: [AnyHashable: Any]
    internal var infoDictionaryURL: URL {
        return Swift.type(of: self).urlForInfoDictionary(forPluginAt: bundle.bundleURL)
    }

    class func urlForInfoDictionary(for plugin: Plugin) -> URL {
        return urlForInfoDictionary(forPluginAt: plugin.bundle.bundleURL)
    }

    class func urlForInfoDictionary(forPluginAt pluginURL: URL) -> URL {
        return pluginURL.appendingPathComponent(ClassConstants.infoDictionaryPathComponent)
    }

    // MARK: Properties

    public dynamic var name: String {
        willSet {
            assert(editable, "The plugin should be editable")
        }
        didSet {
            infoDictionary[InfoDictionaryKeys.name] = name
            save()
        }
    }

    public var identifier: String {
        willSet {
            assert(editable, "The plugin should be editable")
        }
        didSet {
            infoDictionary[InfoDictionaryKeys.identifier] = identifier
            save()
        }
    }

    public dynamic var command: String? {
        willSet {
            assert(editable, "The plugin should be editable")
        }
        didSet {
            infoDictionary[InfoDictionaryKeys.command] = command
            save()
        }
    }

    public var commandPath: String? {
        if let resourcePath = resourcePath {
            if let command = command {
                return resourcePath.appendingPathComponent(command)
            }
        }
        return nil
    }

    public dynamic var suffixes: [String] {
        willSet {
            assert(editable, "The plugin should be editable")
        }
        didSet {
            infoDictionary[InfoDictionaryKeys.suffixes] = suffixes
            save()
        }
    }

    public dynamic var type: String {
        return pluginType.name()
    }

    public dynamic var editable: Bool {
        didSet {
            if !editable {
                infoDictionary[InfoDictionaryKeys.editable] = editable
            } else {
                infoDictionary[InfoDictionaryKeys.editable] = nil
            }
            save()
        }
    }

    // MARK: Save

    private func save() {
        let infoDictionaryURL = self.infoDictionaryURL
        do {
            try Swift.type(of: self).write(infoDictionary, toURL: infoDictionaryURL)
        } catch let PluginWriteError.failToWriteDictionaryError(URL) {
            print("Failed to write an info dictionary at URL \(URL)")
        } catch let error as NSError {
            print("Failed to write an info dictionary \(error)")
        }
    }

    class func write(_ dictionary: [AnyHashable: Any], toURL URL: Foundation.URL) throws {
        let writableDictionary = NSDictionary(dictionary: dictionary)
        let success = writableDictionary.write(to: URL, atomically: true)
        if !success {
            throw PluginWriteError.failToWriteDictionaryError(URL: URL)
        }
    }

    // MARK: Description

    public override var description: String {
        let description = super.description
        return """
        \(description),
        Plugin name = \(name),
        identifier = \(identifier),
        defaultNewPlugin = \(isDefaultNewPlugin),
        hidden = \(hidden),
        editable = \(editable),
        debugModeEnabled = \(String(describing: debugModeEnabled)),
        transparentBackground = \(String(describing: transparentBackground)),
        autoShowLog = \(String(describing: autoShowLog))
        """
    }
}
