//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//


extension Plugin {

    enum PluginLoadError: Error {
        case invalidBundleError(path: String)
        case invalidInfoDictionaryError(URL: URL)
        case invalidFileExtensionsError(infoDictionary: [AnyHashable: Any])
        case invalidCommandError(infoDictionary: [AnyHashable: Any])
        case invalidNameError(infoDictionary: [AnyHashable: Any])
        case invalidIdentifierError(infoDictionary: [AnyHashable: Any])
        case invalidHiddenError(infoDictionary: [AnyHashable: Any])
        case invalidEditableError(infoDictionary: [AnyHashable: Any])
        case invalidDebugModeEnabledError(infoDictionary: [AnyHashable: Any])
    }

    struct InfoDictionaryKeys {
        static let name = "WCName"
        static let identifier = "WCUUID"
        static let command = "WCCommand"
        static let suffixes = "WCFileExtensions"
        static let hidden = "WCHidden"
        static let editable = "WCEditable"
        static let debugModeEnabled = "WCDebugModeEnabled"
    }

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

    class func makePlugin(url: URL) -> Plugin? {
        return self.makePlugin(path: url.path)
    }

    class func makePlugin(path: String) -> Plugin? {
        do {
            let plugin = try validPlugin(path: path)
            return plugin
        } catch PluginLoadError.invalidBundleError(let path) {
            print("Bundle is invalid at path \(path).")
        } catch PluginLoadError.invalidInfoDictionaryError(let URL) {
            print("Info.plist is invalid at URL \(URL).")
        } catch PluginLoadError.invalidFileExtensionsError(let infoDictionary) {
            print("Plugin file extensions are invalid \(infoDictionary).")
        } catch PluginLoadError.invalidCommandError(let infoDictionary) {
            print("Plugin command is invalid \(infoDictionary).")
        } catch PluginLoadError.invalidNameError(let infoDictionary) {
            print("Plugin name is invalid \(infoDictionary).")
        } catch PluginLoadError.invalidIdentifierError(let infoDictionary) {
            print("Plugin UUID is invalid \(infoDictionary).")
        } catch PluginLoadError.invalidHiddenError(let infoDictionary) {
            print("Plugin hidden is invalid \(infoDictionary).")
        } catch PluginLoadError.invalidEditableError(let infoDictionary) {
            print("Plugin editable is invalid \(infoDictionary).")
        } catch PluginLoadError.invalidDebugModeEnabledError(let infoDictionary) {
            print("Plugin debug mode enabled is invalid \(infoDictionary).")
        } catch {
            print("Failed to load plugin at path \(path).")
        }
        
        return nil
    }
    
    class func validPlugin(path: String) throws -> Plugin? {
        do {
            if let bundle = try validBundle(path: path),
                let infoDictionary = try validInfoDictionary(bundle: bundle),
                let identifier = try validIdentifier(infoDictionary: infoDictionary),
                let name = try validName(infoDictionary: infoDictionary)
            {
                // Optional Keys
                let pluginType = validPluginType(path: path)
                let command = try validCommand(infoDictionary: infoDictionary)
                let suffixes = try validSuffixes(infoDictionary: infoDictionary)
                let hidden = try validHidden(infoDictionary: infoDictionary)
                let editable = try validEditable(infoDictionary: infoDictionary)
                let debugModeEnabled = try validDebugModeEnabled(infoDictionary: infoDictionary)
                

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
                    debugModeEnabled: debugModeEnabled)

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

        throw PluginLoadError.invalidBundleError(path: path)
    }
    
    class func validInfoDictionary(bundle: Bundle) throws -> [AnyHashable: Any]? {
        let URL = self.urlForInfoDictionary(forPluginAt: bundle.bundleURL)
        if let infoDictionary = NSDictionary(contentsOf: URL) {
            return infoDictionary as? [AnyHashable: Any]
        }

        throw PluginLoadError.invalidInfoDictionaryError(URL: URL)
    }

    class func validSuffixes(infoDictionary: [AnyHashable: Any]) throws -> [String]? {
        if let suffixes = infoDictionary[InfoDictionaryKeys.suffixes] as? [String] {
            return suffixes
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.suffixes] as AnyObject? {
            // A missing suffixes is valid, but an existing malformed one is not
            throw PluginLoadError.invalidFileExtensionsError(infoDictionary: infoDictionary)
        }

        return nil
    }

    class func validCommand(infoDictionary: [AnyHashable: Any]) throws -> String? {
        if let command = infoDictionary[InfoDictionaryKeys.command] as? String {
            if command.characters.count > 0 {
                return command
            }
        }

        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.command] as AnyObject? {
            // A missing command is valid, but an existing malformed one is not
            throw PluginLoadError.invalidCommandError(infoDictionary: infoDictionary)
        }

        return nil
    }
    
    class func validName(infoDictionary: [AnyHashable: Any]) throws -> String? {
        if let name = infoDictionary[InfoDictionaryKeys.name] as? String {
            if name.characters.count > 0 {
                return name
            }
        }
        
        throw PluginLoadError.invalidNameError(infoDictionary: infoDictionary)
    }
    
    class func validIdentifier(infoDictionary: [AnyHashable: Any]) throws -> String? {
        if let uuidString = infoDictionary[InfoDictionaryKeys.identifier] as? String {
            let uuid: UUID? = UUID(uuidString: uuidString)
            if uuid != nil {
                return uuidString
            }
        }

        throw PluginLoadError.invalidIdentifierError(infoDictionary: infoDictionary)
    }

    class func validHidden(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let hidden = infoDictionary[InfoDictionaryKeys.hidden] as? Int {
            return NSNumber(value: hidden as Int).boolValue
        }
        
        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.hidden] as AnyObject? {
            // A missing hidden is valid, but an existing malformed one is not
            throw PluginLoadError.invalidHiddenError(infoDictionary: infoDictionary)
        }

        return false
    }

    class func validEditable(infoDictionary: [AnyHashable: Any]) throws -> Bool {
        if let editable = infoDictionary[InfoDictionaryKeys.editable] as? NSNumber {
            return editable.boolValue
        }
        
        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.editable] as AnyObject? {
            // A missing editable is valid, but an existing malformed one is not
            throw PluginLoadError.invalidEditableError(infoDictionary: infoDictionary)
        }

        return true
    }

    class func validDebugModeEnabled(infoDictionary: [AnyHashable: Any]) throws -> Bool? {
        if let debugModeEnabled = infoDictionary[InfoDictionaryKeys.debugModeEnabled] as? Int {
            return NSNumber(value: debugModeEnabled as Int).boolValue
        }
        
        if let _: AnyObject = infoDictionary[InfoDictionaryKeys.debugModeEnabled] as AnyObject? {
            // A missing editable is valid, but an existing malformed one is not
            throw PluginLoadError.invalidDebugModeEnabledError(infoDictionary: infoDictionary)
        }
        
        return nil
    }
    
    class func validPluginType(path: String) -> PluginType {
        let pluginContainerDirectory = path.deletingLastPathComponent
        switch pluginContainerDirectory {
        case Directory.applicationSupportPlugins.path():
            return PluginType.user
        case Directory.builtInPlugins.path():
            return PluginType.builtIn
        default:
            return PluginType.other
        }
    }
}
