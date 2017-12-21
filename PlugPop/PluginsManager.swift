//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

// The `POPPluginsController` manages the in memory `Plugin` objects. It
// provides standard methods for operating on a collection of `Plugin` objects.
public class PluginsManager: PluginsDataControllerDelegate {
    
    let pluginsDataController: PluginsDataController
    public var pluginsSource: POPPluginsSource {
        return pluginsController
    }
    let pluginsController: POPPluginsController
    let defaultNewPluginManager: POPDefaultNewPluginManager
    var plugins: [Plugin] {
        return pluginsController.plugins()
    }
    var defaultNewPlugin: Plugin? {
        set {
            defaultNewPluginManager.defaultNewPlugin = newValue
        }
        get {
            return defaultNewPluginManager.defaultNewPlugin as? Plugin
        }
    }
    var sharedResourcesPath: String? {
        guard let plugin = self.plugin(withName: sharedResourcesPluginName) else {
            return nil
        }
        return plugin.resourcePath
    }
    var sharedResourcesURL: URL? {
        guard let plugin = self.plugin(withName: sharedResourcesPluginName) else {
            return nil
        }
        return plugin.resourceURL
    }

    // MARK: Init

    class func makeConfiguration(pluginsPaths: [String],
                                 copyTempDirectoryURL: URL,
                                 defaults: DefaultsType,
                                 userPluginsPath: String,
                                 builtInPluginsPath: String?) -> PluginsManagerConfiguration
    {
        return PluginsManagerConfiguration(pluginsPaths: pluginsPaths,
                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                           defaults: defaults,
                                           userPluginsPath: userPluginsPath,
                                           builtInPluginsPath: builtInPluginsPath)
    }

    public convenience init(pluginsPaths: [String],
                            copyTempDirectoryURL: URL,
                            defaults: DefaultsType,
                            userPluginsPath: String,
                            builtInPluginsPath: String?) {
        let pluginsManagerConfiguration = type(of: self).makeConfiguration(pluginsPaths: pluginsPaths,
                                                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                                                           defaults: defaults,
                                                                           userPluginsPath: userPluginsPath,
                                                                           builtInPluginsPath: builtInPluginsPath)
        self.init(configuration: pluginsManagerConfiguration)
    }

    public required init(configuration: PluginsManagerConfiguration) {
        self.defaultNewPluginManager = configuration.defaultNewPluginManager
        self.pluginsDataController = configuration.pluginsDataController
        self.pluginsController = configuration.pluginsController
        pluginsDataController.delegate = self
        defaultNewPluginManager.dataSource = self.pluginsController
    }

    // MARK: Plugins

    func plugin(withName name: String) -> Plugin? {
        return pluginsController.plugin(withName: name)
    }
    
    func plugin(withIdentifier identifier: String) -> Plugin? {
        return pluginsController.plugin(withIdentifier: identifier)
    }

    // MARK: Convenience
    
    func addUnwatched(_ plugin: Plugin) {
        // TODO: For now this is a big hack, this adds a plugin that isn't
        // managed by the PluginDataManager. This means if the plugin moves on
        // the file system for example, that the loaded plugin will be
        // out-of-date.
        add(plugin)
    }
    
    private func add(_ plugin: Plugin) {
        pluginsController.add(plugin)
    }
    
    private func remove(_ plugin: Plugin) {
        pluginsController.remove(plugin)
    }
    
    // MARK: Adding and Removing Plugins
    
    func moveToTrash(_ plugin: Plugin, handler: ((_ error: Error?) -> Void)?) {
        pluginsDataController.moveToTrash(plugin, handler: handler)
    }
    
    func duplicate(_ plugin: Plugin, handler: ((_ newPlugin: Plugin?, _ error: NSError?) -> Void)?) {
        pluginsDataController.duplicate(plugin, handler: handler)
    }

    func newPlugin(handler: ((_ newPlugin: Plugin?, _ error: NSError?) -> Void)?) {
        // TODO: Handle when the `defaultNewPlugin` is nil. This isn't an issue
        // right now only because it's impossible to run the app that way
        // without tampering with the bundle contents.
        if let plugin = defaultNewPluginManager.defaultNewPlugin as? Plugin {
            duplicate(plugin, handler: handler)
        }
    }

    // MARK: PluginsDataControllerDelegate

    func pluginsDataController(_ pluginsDataController: PluginsDataController, 
                               didAddPlugin plugin: Plugin) 
    {
        add(plugin)
    }

    func pluginsDataController(_ pluginsDataController: PluginsDataController, 
                               didRemovePlugin plugin: Plugin) 
    {
        if 
           let defaultNewPlugin = defaultNewPluginManager.defaultNewPlugin as? Plugin,
           defaultNewPlugin == plugin
        {
            defaultNewPluginManager.defaultNewPlugin = nil
        }
        remove(plugin)
    }

    func pluginsDataController(_  pluginsDataController: PluginsDataController,
                               uniquePluginNameFromName name: String,
                               for plugin: Plugin) -> String?
    {
        return pluginsController.uniquePluginName(fromName: name, for: plugin)
    }

}
