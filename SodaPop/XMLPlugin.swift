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

class XMLPlugin: Plugin {
    class func validPlugin(path: String, pluginType: PluginKind) throws -> Plugin? {
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
                return Plugin(bundle: bundle,
                              infoDictionary: infoDictionary,
                              pluginType: pluginType,
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

        return false
    }

    class func validEditable(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let editable = infoDictionary[InfoDictionaryKeys.editable] as? NSNumber {
            return editable.boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.editable] as AnyObject? {
            throw XMLPluginLoadError.invalidEditableError(infoDictionary: infoDictionary)
        }

        return true
    }

    class func validPromptInterrupt(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let promptInterrupt = infoDictionary[InfoDictionaryKeys.promptInterrupt] as? Int {
            return NSNumber(value: promptInterrupt as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.promptInterrupt] as AnyObject? {
            throw XMLPluginLoadError.invalidPromptInterruptError(infoDictionary: infoDictionary)
        }

        return false
    }

    class func validUsesEnvironment(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let usesEnvironment = infoDictionary[InfoDictionaryKeys.usesEnvironment] as? Int {
            return NSNumber(value: usesEnvironment as Int).boolValue
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.usesEnvironment] as AnyObject? {
            throw XMLPluginLoadError.invalidUsesEnvironmentError(infoDictionary: infoDictionary)
        }

        return false
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

        return false
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
