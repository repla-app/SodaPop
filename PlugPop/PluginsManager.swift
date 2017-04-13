//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginsManager: WCLPluginsManager, PluginsDataControllerDelegate {
    
    let pluginsDataController: PluginsDataController
    
    // MARK: Singleton
    
    struct Singleton {
        static let instance: PluginsManager = PluginsManager()
        static var overrideSharedInstance: PluginsManager?
    }

    class var sharedInstance: PluginsManager {
        if let overrideSharedInstance = Singleton.overrideSharedInstance {
            return overrideSharedInstance
        }
        
        return Singleton.instance
    }

    class func setOverrideSharedInstance(_ pluginsManager: PluginsManager?) {
        Singleton.overrideSharedInstance = pluginsManager
    }

    // MARK: Init
    
    init(paths: [String], duplicatePluginDestinationDirectoryURL: URL) {
        self.pluginsDataController = PluginsDataController(paths: paths, duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        super.init(plugins: pluginsDataController.plugins())
        pluginsDataController.delegate = self
    }
    
    convenience override init() {
        self.init(paths: [Directory.builtInPlugins.path(), Directory.applicationSupportPlugins.path()], duplicatePluginDestinationDirectoryURL: Directory.applicationSupportPlugins.URL())
    }

    
    // MARK: Accessing Plugins
    
    func plugin(forName name: String) -> Plugin? {
        return pluginsController.object(forKey: name) as? Plugin
    }
    
    func plugin(withIdentifier identifier: String) -> Plugin? {
        guard let allPlugins = plugins() as? [Plugin] else {
            return nil
        }
        
        for plugin in allPlugins {
            if plugin.identifier == identifier {
                return plugin
            }
        }
        return nil
    }


    // MARK: Convenience
    
    func addUnwatched(_ plugin: Plugin) {
        // TODO: For now this is a big hack, this adds a plugin that isn't managed by the PluginDataManager.
        // This means if the plugin moves on the file system for example, that the loaded plugin will be out-of-date.
        add(plugin)
    }
    
    private func add(_ plugin: Plugin) {
        insertObject(plugin, inPluginsAt: 0)
    }
    
    private func remove(_ plugin: Plugin) {
        let index = pluginsController.indexOfObject(plugin)
        if index != NSNotFound {
            removeObjectFromPlugins(at: UInt(index))
        }
    }
    

    // MARK: Adding and Removing Plugins
    
    func moveToTrash(_ plugin: Plugin) {
        pluginsDataController.moveToTrash(plugin)
    }
    
    func duplicate(_ plugin: Plugin, handler: ((_ newPlugin: Plugin?, _ error: NSError?) -> Void)?) {
        pluginsDataController.duplicate(plugin, handler: handler)
    }

    func newPlugin(handler: ((_ newPlugin: Plugin?, _ error: NSError?) -> Void)?) {
        // May need to handle the case when no default new plugin is define in the future, but for now the fallback to the initial plugin should always work

        if let plugin = defaultNewPlugin {
            duplicate(plugin, handler: handler)
        }
    }

    // MARK: PluginsDataControllerDelegate

    func pluginsDataController(_ pluginsDataController: PluginsDataController, didAddPlugin plugin: Plugin) {
        add(plugin)
    }


    func pluginsDataController(_ pluginsDataController: PluginsDataController, didRemovePlugin plugin: Plugin) {
        if let unwrappedDefaultNewPlugin = defaultNewPlugin {
            if unwrappedDefaultNewPlugin == plugin {
                defaultNewPlugin = nil
            }
        }
        remove(plugin)
    }


    // MARK: Shared Resources

    func sharedResourcesPath() -> String? {
        let plugin = self.plugin(forName: sharedResourcesPluginName)
        return plugin?.resourcePath
    }

    func sharedResourcesURL() -> URL? {
        let plugin = self.plugin(forName: sharedResourcesPluginName)
        return plugin?.resourceURL as URL?
    }
}
