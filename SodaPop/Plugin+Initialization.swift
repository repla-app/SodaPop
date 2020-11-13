//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import StringPlusPath

enum PluginType {
    case builtIn, user, other
    func name() -> String {
        switch self {
        case .builtIn:
            return "Built-In"
        case .user:
            return "User"
        case .other:
            return "Other"
        }
    }
}

extension Plugin {

    struct InfoDictionaryKeys {
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

    @objc public class func makePlugin(url: URL) -> Plugin? {
        return makePlugin(path: url.path)
    }

    class func makePlugin(url: URL, pluginType: PluginType = .other) -> Plugin? {
        return makePlugin(path: url.path, pluginType: pluginType)
    }

    class func makePlugin(path: String, pluginType: PluginType = .other) -> Plugin? {
        do {
            let plugin = try XMLPlugin.validPlugin(path: path, pluginType: pluginType)
            return plugin
        } catch let XMLPluginLoadError.invalidBundleError(path) {
            print("Bundle is invalid at path \(path).")
        } catch let XMLPluginLoadError.invalidInfoDictionaryError(URL) {
            print("Info.plist is invalid at URL \(URL).")
        } catch let XMLPluginLoadError.invalidFileExtensionsError(infoDictionary) {
            print("Plugin file extensions are invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidCommandError(infoDictionary) {
            print("Plugin command is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidNameError(infoDictionary) {
            print("Plugin name is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidIdentifierError(infoDictionary) {
            print("Plugin UUID is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidHiddenError(infoDictionary) {
            print("Plugin hidden is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidEditableError(infoDictionary) {
            print("Plugin editable is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidPromptInterruptError(infoDictionary) {
            print("Plugin prompt interrupt is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidUsesEnvironmentError(infoDictionary) {
            print("Plugin uses environment is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidDebugModeEnabledError(infoDictionary) {
            print("Plugin debug mode enabled is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidAutoShowLogError(infoDictionary) {
            print("Plugin auto-show log is invalid \(infoDictionary).")
        } catch let XMLPluginLoadError.invalidTransparentBackgroundError(infoDictionary) {
            print("Plugin transparent background is invalid \(infoDictionary).")
        } catch {
            print("Failed to load plugin at path \(path).")
        }

        return nil
    }
}
