//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

protocol PluginsDataControllerDelegate {
    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               didAddPlugin plugin: Plugin)
    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               didRemovePlugin plugin: Plugin)
    func pluginsDataController(_  pluginsDataController: PluginsDataController,
                               uniquePluginNameFromName name: String,
                               for plugin: Plugin) -> String?
}

// `PluginsDataController`: The `PluginsDataController` abstracts away the
// file-system, it fires delegate messages when `Plugin` files are added to a
// `Plugin` directory. It's also responsible for the performing file-system
// level operations related to `Plugin`, such as duplicating `Plugin` files and
// moving `Plugin` files to the trash.
class PluginsDataController: PluginsDirectoryManagerDelegate, DuplicatePluginControllerDelegate {

    var delegate: PluginsDataControllerDelegate?
    var pluginDirectoryManagers: [PluginsDirectoryManager]!
    var pluginPathToPluginDictionary: [String : Plugin]!
    lazy var duplicatePluginController: DuplicatePluginController = {
        let duplicatePluginController = DuplicatePluginController(pluginMaker: self.pluginMaker)
        duplicatePluginController.delegate = self
        return duplicatePluginController
    }()
    let pluginMaker: PluginMaker
    let duplicatePluginDestinationDirectoryURL: URL
    let copyTempDirectoryURL: URL
    
    init(paths: [String],
         duplicatePluginDestinationDirectoryURL: URL,
         copyTempDirectoryURL: URL,
         builtInPluginsPath: String?,
         applicationSupportPluginsPath: String?)
    {
        self.pluginMaker = PluginMaker(builtInPluginsPath: builtInPluginsPath,
                                       applicationSupportPluginsPath: applicationSupportPluginsPath)
        self.pluginDirectoryManagers = [PluginsDirectoryManager]()
        self.pluginPathToPluginDictionary = [String : Plugin]()
        self.duplicatePluginDestinationDirectoryURL = duplicatePluginDestinationDirectoryURL

        let pathsSet = Set(paths + [builtInPluginsPath, applicationSupportPluginsPath])
        for path in pathsSet {
            let plugins = self.plugins(atPath: path)
            for plugin in plugins {
                pluginPathToPluginDictionary[plugin.bundle.bundlePath] = plugin
            }
            let pluginsDirectoryURL = URL(fileURLWithPath: path)
            let pluginDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: pluginsDirectoryURL)
            pluginDirectoryManager.delegate = self
            pluginDirectoryManagers.append(pluginDirectoryManager)
        }
    }

    // MARK: Plugins

    func plugins() -> [Plugin] {
        return Array(pluginPathToPluginDictionary.values)
    }
    
    // MARK: PluginsDirectoryManagerDelegate

    func pluginsDirectoryManager(_ pluginsDirectoryManager: PluginsDirectoryManager,
        pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: String)
    {
        if let oldPlugin = plugin(atPluginPath: pluginPath) {
            if let newPlugin = Plugin.makePlugin(path: pluginPath) {
                // If there is an existing plugin and a new plugin, remove the old plugin and add the new plugin
                if !oldPlugin.isEqual(to: newPlugin) {
                    remove(oldPlugin)
                    add(newPlugin)
                }
            }
        } else {
            // If there is only a new plugin, add it
            if let newPlugin = Plugin.makePlugin(path: pluginPath) {
                add(newPlugin)
            }
        }
    }
    
    func pluginsDirectoryManager(_ pluginsDirectoryManager: PluginsDirectoryManager,
                                 pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: String)
    {
        if let oldPlugin = plugin(atPluginPath: pluginPath) {
            remove(oldPlugin)
        }
    }
    // MARK: DuplicatePluginControllerDelegate

    func duplicatePluginController(_  duplicatePluginController: DuplicatePluginController,
                                   uniquePluginNameFromName name: String,
                                   for plugin: Plugin) -> String?
    {
        return self.delegate?.pluginsDataController(self,
                                                    uniquePluginNameFromName: name,
                                                    for: plugin)
    }

    // MARK: Add & Remove Helpers
    
    func add(_ plugin: Plugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary[pluginPath] = plugin
        delegate?.pluginsDataController(self, didAddPlugin: plugin)
    }
    
    func remove(_ plugin: Plugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary.removeValue(forKey: pluginPath)
        delegate?.pluginsDataController(self, didRemovePlugin: plugin)
    }
    
    func plugin(atPluginPath pluginPath: String) -> Plugin? {
        return pluginPathToPluginDictionary[pluginPath]
    }

    // MARK: Duplicate and Remove

    func moveToTrash(_ plugin: Plugin) {
        assert(plugin.editable, "The plugin should be editable")
        remove(plugin)
        let pluginPath = plugin.bundle.bundlePath
        let pluginDirectoryPath = pluginPath.deletingLastPathComponent
        let pluginDirectoryName = pluginPath.lastPathComponent
        NSWorkspace.shared().performFileOperation(NSWorkspaceRecycleOperation,
            source: pluginDirectoryPath,
            destination: "",
            files: [pluginDirectoryName],
            tag: nil)
        let exists = FileManager.default.fileExists(atPath: pluginPath)
        assert(!exists, "The file should not exist")
    }
    
    func duplicate(_ plugin: Plugin,
                   handler: ((_ plugin: Plugin?, _ error: NSError?) -> Void)?)
    {
        do {
            try type(of: self).createDirectoryIfMissing(at: duplicatePluginDestinationDirectoryURL)
        } catch let error as NSError {
            handler?(nil, error)
            return
        }

        duplicatePluginController.duplicate(plugin,
            to: duplicatePluginDestinationDirectoryURL)
        { (plugin, error) -> Void in
            if let plugin = plugin {
                self.add(plugin)
            }
            handler?(plugin, error)
        }
    }

    class func createDirectoryIfMissing(at directoryURL: URL) throws {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: directoryURL.path,
                                                    isDirectory: &isDir)
        if (exists && isDir.boolValue) {
            return
        }
        
        if (exists && !isDir.boolValue) {
            throw FileSystemError.fileExistsForDirectoryError
        }

        do {
            try FileManager.default.createDirectory(at: directoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch let error as NSError {
            throw error
        }
    }
    
}
