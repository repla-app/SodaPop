//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import StringPlusPath

public enum PluginKind {
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
    static var forceXML: Bool = defaultForceXML
    public class func makePlugin(url: URL) -> Plugin? {
        return makePlugin(path: url.path)
    }

    class func makePlugin(url: URL, pluginKind: PluginKind = .other) -> Plugin? {
        return makePlugin(path: url.path, pluginKind: pluginKind)
    }

    class func makePlugin(path: String, pluginKind: PluginKind = .other) -> Plugin? {
        do {
            guard !forceXML else {
                return try XMLPlugin.validPlugin(path: path, pluginKind: pluginKind)
            }
            return try JSONPlugin.validPlugin(path: path, pluginKind: pluginKind)
        } catch let JSONPluginLoadError.loadPluginInfoFailed(path: path, underlyingError: error) {
            print("Faile to load JSON plugin at path \(path), error \(error?.description ?? "nil").")
            return makeXMLPlugin(path: path, pluginKind: pluginKind)
        } catch let XMLPluginLoadError.invalidBundleError(path) {
            print("Bundle is invalid at path \(path).")
        } catch {
            guard !forceXML else {
                return try? JSONPlugin.validPlugin(path: path, pluginKind: pluginKind)
            }
            print("Failed to load JSON plugin at path \(path).")
        }
        return nil
    }
    
    class func makeXMLPlugin(path: String, pluginKind: PluginKind = .other) -> XMLPlugin? {
        do {
            let plugin = try XMLPlugin.validPlugin(path: path, pluginKind: pluginKind)
            return plugin
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
            print("Failed to load XML plugin at path \(path).")
        }
        
        return nil
    }
}
