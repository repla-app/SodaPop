//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import PlainBagel

// The `POPPluginsController` manages the in memory `Plugin` objects. It
// provides standard methods for operating on a collection of `Plugin` objects.

@objcMembers
public class PluginsManager: NSObject, PluginsDataControllerDelegate {
    let pluginsDataController: PluginsDataController
    public var pluginsSource: POPPluginsSource {
        return pluginsController
    }

    let pluginsController: POPPluginsController
    let defaultNewPluginManager: POPDefaultNewPluginManager
    public var plugins: [Plugin] {
        return pluginsController.plugins()
    }

    public var defaultNewPlugin: Plugin? {
        get {
            return defaultNewPluginManager.defaultNewPlugin as? Plugin
        }
        set {
            defaultNewPluginManager.defaultNewPlugin = newValue
        }
    }

    // MARK: Init

    public class func makeConfiguration(pluginsPaths: [String],
                                        copyTempDirectoryURL: URL,
                                        defaults: DefaultsType,
                                        fallbackDefaultNewPluginName: String,
                                        userPluginsPath: String,
                                        builtInPluginsPath: String?) -> PluginsManagerConfiguration {
        return PluginsManagerConfiguration(pluginsPaths: pluginsPaths,
                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                           defaults: defaults,
                                           fallbackDefaultNewPluginName: fallbackDefaultNewPluginName,
                                           userPluginsPath: userPluginsPath,
                                           builtInPluginsPath: builtInPluginsPath)
    }

    public convenience init(pluginsPaths: [String],
                            copyTempDirectoryURL: URL,
                            defaults: DefaultsType,
                            fallbackDefaultNewPluginName: String,
                            userPluginsPath: String,
                            builtInPluginsPath: String?) {
        let pluginsManagerConfiguration = type(of: self).makeConfiguration(pluginsPaths: pluginsPaths,
                                                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                                                           defaults: defaults,
                                                                           fallbackDefaultNewPluginName:
                                                                           fallbackDefaultNewPluginName,
                                                                           userPluginsPath: userPluginsPath,
                                                                           builtInPluginsPath: builtInPluginsPath)
        self.init(configuration: pluginsManagerConfiguration)
    }

    public required init(configuration: PluginsManagerConfiguration) {
        defaultNewPluginManager = configuration.defaultNewPluginManager
        pluginsDataController = configuration.pluginsDataController
        pluginsController = configuration.pluginsController
        super.init()
        pluginsDataController.delegate = self
        defaultNewPluginManager.dataSource = pluginsController
    }

    // MARK: Plugins

    public func plugin(withName name: String) -> Plugin? {
        return pluginsController.plugin(withName: name)
    }

    public func plugin(withIdentifier identifier: String) -> Plugin? {
        return pluginsController.plugin(withIdentifier: identifier)
    }

    public func isUnique(name: String, for plugin: Plugin) -> Bool {
        return pluginsController.isUniqueName(name, for: plugin)
    }

    // MARK: Convenience

    public func addUnwatched(_ plugin: Plugin) {
        // TODO: For now this is a big hack, this adds a plugin that isn't
        // managed by the PluginDataManager. This means if the plugin moves on
        // the file system for example, that the loaded plugin will be
        // out-of-date.
        // Remove the plugin first in case it has already been added
        if let existingPlugin = self.plugin(withName: plugin.name) {
            remove(existingPlugin)
        }
        add(plugin)
    }

    public func removeUnwatched(_ plugin: Plugin) {
        remove(plugin)
    }

    private func add(_ plugin: Plugin) {
        pluginsController.add(plugin)
    }

    private func remove(_ plugin: Plugin) {
        pluginsController.remove(plugin)
    }

    // MARK: Adding and Removing Plugins

    public func moveToTrash(_ plugin: Plugin, handler: ((_ url: URL?, _ error: Error?) -> Void)?) {
        pluginsDataController.moveToTrash(plugin, handler: handler)
    }

    public func duplicate(_ plugin: Plugin, handler: ((_ newPlugin: Plugin?, _ error: NSError?) -> Void)?) {
        pluginsDataController.duplicate(plugin, handler: handler)
    }

    public func newPlugin(handler: ((_ newPlugin: Plugin?, _ error: NSError?) -> Void)?) {
        // TODO: Handle when the `defaultNewPlugin` is nil. This isn't an issue
        // right now only because it's impossible to run the app that way
        // without tampering with the bundle contents.
        if let plugin = defaultNewPluginManager.defaultNewPlugin as? Plugin {
            duplicate(plugin, handler: handler)
        }
    }

    // MARK: PluginsDataControllerDelegate

    func pluginsDataController(_: PluginsDataController,
                               didAddPlugin plugin: Plugin) {
        add(plugin)
    }

    func pluginsDataController(_: PluginsDataController,
                               didRemovePlugin plugin: Plugin) {
        if
            let defaultNewPlugin = defaultNewPluginManager.defaultNewPlugin as? Plugin,
            defaultNewPlugin == plugin
        {
            defaultNewPluginManager.defaultNewPlugin = nil
        }
        remove(plugin)
    }

    func pluginsDataController(_: PluginsDataController,
                               uniquePluginNameFromName name: String,
                               for plugin: Plugin) -> String? {
        return pluginsController.uniquePluginName(fromName: name, for: plugin)
    }

    override public var description: String {
        return "pluginsDataController = \(pluginsDataController)"
    }
}
