//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

// The `WCLPluginsController` manages the in memory `Plugin` objects. It
// provides standard methods for operating on a collection of `Plugin` objects.
class PluginsManager: PluginsDataControllerDelegate {
    
    let pluginsDataController: PluginsDataController
    let pluginsController: WCLPluginsController
    let defaultNewPluginManager: WCLDefaultNewPluginManager
    
    // MARK: Init
    
    init(paths: [String],
         duplicatePluginDestinationDirectoryURL: URL,
         copyTempDirectoryURL: URL,
         defaults: DefaultsType,
         builtInPluginsPath: String?,
         applicationSupportPluginsPath: String?)
    {
        self.defaultNewPluginManager = WCLDefaultNewPluginManager(defaults: defaults)
        self.pluginsDataController = PluginsDataController(paths: paths,
                                                           duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL,
                                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                                           defaultNewPluginManager: defaultNewPluginManager,
                                                           builtInPluginsPath: builtInPluginsPath,
                                                           applicationSupportPluginsPath: applicationSupportPluginsPath)
        self.pluginsController = WCLPluginsController(plugins: pluginsDataController.plugins())
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
        pluginsController.addPlugin(plugin)
    }
    
    private func remove(_ plugin: Plugin) {
        pluginsController.removePlugin(plugin)
    }
    
    // MARK: Adding and Removing Plugins
    
    func moveToTrash(_ plugin: Plugin) {
        pluginsDataController.moveToTrash(plugin)
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

    // MARK: Shared Resources

    func sharedResourcesPath() -> String? {
        let plugin = self.plugin(withName: sharedResourcesPluginName)
        return plugin?.resourcePath
    }

    func sharedResourcesURL() -> URL? {
        let plugin = self.plugin(withName: sharedResourcesPluginName)
        return plugin?.resourceURL as URL?
    }
}
