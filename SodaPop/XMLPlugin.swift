//
//  XMLPlugin.swift
//  SodaPop
//
//  Created by Roben Kleene on 11/13/20.
//  Copyright © 2020 Roben Kleene. All rights reserved.
//

import Cocoa

enum XMLPluginLoadError: Error {
    case invalidBundleError(path: String)
    case invalidInfoDictionaryError(URL: URL)
    case invalidFileExtensionsError(infoDictionary: [AnyHashable: Any])
    case invalidCommandError(infoDictionary: [AnyHashable: Any])
    case invalidNameError(infoDictionary: [AnyHashable: Any])
    case invalidIdentifierError(infoDictionary: [AnyHashable: Any])
    case invalidHiddenError(infoDictionary: [AnyHashable: Any])
    case invalidEditableError(infoDictionary: [AnyHashable: Any])
    case invalidDebugModeEnabledError(infoDictionary: [AnyHashable: Any])
    case invalidAutoShowLogError(infoDictionary: [AnyHashable: Any])
    case invalidTransparentBackgroundError(infoDictionary: [AnyHashable: Any])
    case invalidPromptInterruptError(infoDictionary: [AnyHashable: Any])
    case invalidUsesEnvironmentError(infoDictionary: [AnyHashable: Any])
}

extension XMLPlugin {
    enum InfoDictionaryKeys {
        static let name = "WCName"
        static let identifier = "WCUUID"
        static let command = "WCCommand"
        static let suffixes = "WCFileExtensions"
        static let hidden = "WCHidden"
        static let editable = "WCEditable"
        static let debugModeEnabled = "WCDebugModeEnabled"
        static let transparentBackground = "WCTransparentBackground"
        static let autoShowLog = "WCAutoShowLog"
        static let promptInterrupt = "WCPromptInterrupt"
        static let usesEnvironment = "WCUsesEnvironment"
    }

    class func validPlugin(path: String, pluginKind: PluginKind) throws -> XMLPlugin? {
        do {
            if let bundle = try validBundle(path: path),
                let infoDictionary = try validInfoDictionary(bundle: bundle),
                let identifier = try validIdentifier(infoDictionary: infoDictionary),
                let name = try validName(infoDictionary: infoDictionary) {
                // Optional Keys
                let command = try validCommand(infoDictionary: infoDictionary)
                let suffixes = try validSuffixes(infoDictionary: infoDictionary)
                let hidden = try validHidden(infoDictionary: infoDictionary)
                let editable = try validEditable(infoDictionary: infoDictionary)
                let debugModeEnabled = try validDebugModeEnabled(infoDictionary: infoDictionary)
                let transparentBackground = try validTransparentBackground(infoDictionary: infoDictionary)
                let autoShowLog = try validAutoShowLog(infoDictionary: infoDictionary)
                let promptInterrupt = try validPromptInterrupt(infoDictionary: infoDictionary)
                let usesEnvironment = try validUsesEnvironment(infoDictionary: infoDictionary)

                // Plugin
                return XMLPlugin(bundle: bundle,
                                 infoDictionary: infoDictionary,
                                 kind: pluginKind,
                                 identifier: identifier,
                                 name: name,
                                 command: command,
                                 suffixes: suffixes,
                                 hidden: hidden,
                                 editable: editable,
                                 debugModeEnabled: debugModeEnabled,
                                 transparentBackground: transparentBackground,
                                 autoShowLog: autoShowLog,
                                 promptInterrupt: promptInterrupt,
                                 usesEnvironment: usesEnvironment)
            }
        } catch let error as NSError {
            throw error
        }

        return nil
    }

    // MARK: Info Dictionary

    class func validBundle(path: String) throws -> Bundle? {
        if let bundle = Bundle(path: path) as Bundle? {
            return bundle
        }

        throw XMLPluginLoadError.invalidBundleError(path: path)
    }

    class func validInfoDictionary(bundle: Bundle) throws -> [AnyHashable: Any]? {
        let URL = urlForInfoDictionary(forPluginAt: bundle.bundleURL)
        if let infoDictionary = NSDictionary(contentsOf: URL) {
            return infoDictionary as? [AnyHashable: Any]
        }

        throw XMLPluginLoadError.invalidInfoDictionaryError(URL: URL)
    }

    class func validSuffixes(infoDictionary: [AnyHashable: Any]) throws -> [String]? {
        if let suffixes = infoDictionary[InfoDictionaryKeys.suffixes] as? [String] {
            return suffixes
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.suffixes] as AnyObject? {
            // A missing suffixes is valid, but an existing malformed one is not
            throw XMLPluginLoadError.invalidFileExtensionsError(infoDictionary: infoDictionary)
        }

        return nil
    }

    class func validCommand(infoDictionary: [AnyHashable: Any]) throws -> String? {
        if let command = infoDictionary[InfoDictionaryKeys.command] as? String {
            if command.count > 0 {
                return command
            }
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.command] as AnyObject? {
            // A missing command is valid, but an existing malformed one is not
            throw XMLPluginLoadError.invalidCommandError(infoDictionary: infoDictionary)
        }

        return nil
    }

    class func validName(infoDictionary: [AnyHashable: Any]) throws -> String? {
        if let name = infoDictionary[InfoDictionaryKeys.name] as? String {
            if name.count > 0 {
                return name
            }
        }

        throw XMLPluginLoadError.invalidNameError(infoDictionary: infoDictionary)
    }

    class func validIdentifier(infoDictionary: [AnyHashable: Any]) throws -> String? {
        if let uuidString = infoDictionary[InfoDictionaryKeys.identifier] as? String {
            let uuid: UUID? = UUID(uuidString: uuidString)
            if uuid != nil {
                return uuidString
            }
        }

        throw XMLPluginLoadError.invalidIdentifierError(infoDictionary: infoDictionary)
    }

    class func validHidden(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let hidden = infoDictionary[InfoDictionaryKeys.hidden] as? Int {
            return NSNumber(value: hidden as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.hidden] as AnyObject? {
            // A missing hidden is valid, but an existing malformed one is not
            throw XMLPluginLoadError.invalidHiddenError(infoDictionary: infoDictionary)
        }

        return defaultPluginHidden
    }

    class func validEditable(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let editable = infoDictionary[InfoDictionaryKeys.editable] as? NSNumber {
            return editable.boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.editable] as AnyObject? {
            throw XMLPluginLoadError.invalidEditableError(infoDictionary: infoDictionary)
        }

        return defaultPluginEditable
    }

    class func validPromptInterrupt(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let promptInterrupt = infoDictionary[InfoDictionaryKeys.promptInterrupt] as? Int {
            return NSNumber(value: promptInterrupt as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.promptInterrupt] as AnyObject? {
            throw XMLPluginLoadError.invalidPromptInterruptError(infoDictionary: infoDictionary)
        }

        return defaultPluginPromptInterrupt
    }

    class func validUsesEnvironment(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let usesEnvironment = infoDictionary[InfoDictionaryKeys.usesEnvironment] as? Int {
            return NSNumber(value: usesEnvironment as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.usesEnvironment] as AnyObject? {
            throw XMLPluginLoadError.invalidUsesEnvironmentError(infoDictionary: infoDictionary)
        }

        return defaultPluginUsesEnvironment
    }

    class func validDebugModeEnabled(infoDictionary: [AnyHashable: Any]) throws -> Bool? {
        if let debugModeEnabled = infoDictionary[InfoDictionaryKeys.debugModeEnabled] as? Int {
            return NSNumber(value: debugModeEnabled as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.debugModeEnabled] as AnyObject? {
            throw XMLPluginLoadError.invalidDebugModeEnabledError(infoDictionary: infoDictionary)
        }

        return nil
    }

    class func validTransparentBackground(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let transparentBackground = infoDictionary[InfoDictionaryKeys.transparentBackground] as? Int {
            return NSNumber(value: transparentBackground as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.transparentBackground] as AnyObject? {
            throw XMLPluginLoadError.invalidTransparentBackgroundError(infoDictionary: infoDictionary)
        }

        return defaultPluginTransparentBackground
    }

    class func validAutoShowLog(infoDictionary: [AnyHashable: Any]) throws -> Bool? {
        if let autoShowLog = infoDictionary[InfoDictionaryKeys.autoShowLog] as? Int {
            return NSNumber(value: autoShowLog as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.autoShowLog] as AnyObject? {
            throw XMLPluginLoadError.invalidAutoShowLogError(infoDictionary: infoDictionary)
        }

        return nil
    }
}

class XMLPlugin: Plugin {
    let bundle: Bundle

    enum PluginWriteError: Error {
        case failToWriteDictionaryError(URL: URL)
    }

    init(bundle: Bundle,
         infoDictionary: [AnyHashable: Any],
         kind: PluginKind,
         identifier: String,
         name: String,
         command: String?,
         suffixes: [String]?,
         hidden: Bool,
         editable: Bool,
         debugModeEnabled: Bool?,
         transparentBackground: Bool,
         autoShowLog: Bool?,
         promptInterrupt: Bool,
         usesEnvironment: Bool) {
        self.bundle = bundle
        self.infoDictionary = infoDictionary
        // FIXME: Add asserts for `nil` `bundle.resourcePath` and `bundle.resourceURL`
        super.init(autoShowLog: autoShowLog,
                   debugModeEnabled: debugModeEnabled,
                   hidden: hidden,
                   promptInterrupt: promptInterrupt,
                   transparentBackground: transparentBackground,
                   usesEnvironment: usesEnvironment,
                   path: bundle.bundlePath,
                   url: bundle.bundleURL,
                   resourcePath: bundle.resourcePath ?? "",
                   kind: kind,
                   resourceURL: bundle.resourceURL ?? URL(string: "")!,
                   editable: editable,
                   command: command,
                   identifier: identifier,
                   name: name,
                   suffixes: suffixes)
    }

    // MARK: Paths

    internal var infoDictionary: [AnyHashable: Any]
    internal var infoDictionaryURL: URL {
        return Swift.type(of: self).urlForInfoDictionary(forPluginAt: bundle.bundleURL)
    }

    class func urlForInfoDictionary(for plugin: Plugin) -> URL {
        return urlForInfoDictionary(forPluginAt: plugin.url)
    }

    class func urlForInfoDictionary(forPluginAt pluginURL: URL) -> URL {
        return pluginURL.appendingPathComponent(infoDictionaryPathComponent)
    }

    // MARK: Properties

    override public dynamic var name: String {
        didSet {
            infoDictionary[InfoDictionaryKeys.name] = name
            save()
        }
    }

    override public var identifier: String {
        didSet {
            infoDictionary[InfoDictionaryKeys.identifier] = identifier
            save()
        }
    }

    override public dynamic var command: String? {
        didSet {
            infoDictionary[InfoDictionaryKeys.command] = command
            save()
        }
    }

    override public dynamic var suffixes: [String]? {
        didSet {
            infoDictionary[InfoDictionaryKeys.suffixes] = suffixes
            save()
        }
    }

    override public dynamic var editable: Bool {
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
        assert(Thread.isMainThread)
        let writableDictionary = NSDictionary(dictionary: dictionary)
        let success = writableDictionary.write(to: URL, atomically: true)
        if !success {
            throw PluginWriteError.failToWriteDictionaryError(URL: URL)
        }
    }

    // MARK: Description

    override public var description: String {
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
