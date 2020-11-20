//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

enum FileSystemError: Error {
    case fileExistsForDirectoryError
}

protocol PluginsDataControllerDelegate: class {
    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               didAddPlugin plugin: BasePlugin)
    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               didRemovePlugin plugin: BasePlugin)
    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               uniquePluginNameFromName name: String,
                               for plugin: BasePlugin) -> String?
}

// `PluginsDataController`: The `PluginsDataController` abstracts away the
// file-system, it fires delegate messages when `Plugin` files are added to a
// `Plugin` directory. It's also responsible for the performing file-system
// level operations related to `Plugin`, such as duplicating `Plugin` files and
// moving `Plugin` files to the trash.
class PluginsDataController: PluginsDirectoryManagerDelegate,
    DuplicatePluginControllerDelegate,
    CustomStringConvertible {
    weak var delegate: PluginsDataControllerDelegate?
    var pluginDirectoryManagers: [PluginsDirectoryManager]
    var pluginPathToPluginDictionary: [String: BasePlugin]
    lazy var duplicatePluginController: DuplicatePluginController = {
        let duplicatePluginController = DuplicatePluginController(pluginMaker: self.pluginMaker,
                                                                  copyTempDirectoryURL: self.copyTempDirectoryURL)
        duplicatePluginController.delegate = self
        return duplicatePluginController
    }()

    let pluginMaker: PluginMaker
    let duplicatePluginDestinationDirectoryURL: URL
    let copyTempDirectoryURL: URL
    var plugins: [BasePlugin] {
        return Array(pluginPathToPluginDictionary.values)
    }

    var pluginsController: POPPluginsController? {
        didSet {
            pluginMaker.pluginsController = pluginsController
            for plugin in plugins {
                plugin.uniqueNameDataSource = pluginsController
            }
        }
    }

    required init(pluginsPaths: [String],
                  copyTempDirectoryURL: URL,
                  defaultNewPluginManager: POPDefaultNewPluginManager,
                  userPluginsPath: String,
                  builtInPluginsPath: String?) {
        pluginMaker = PluginMaker(defaultNewPluginManager: defaultNewPluginManager,
                                  userPluginsPath: userPluginsPath,
                                  builtInPluginsPath: builtInPluginsPath)
        pluginDirectoryManagers = [PluginsDirectoryManager]()
        pluginPathToPluginDictionary = [String: BasePlugin]()
        duplicatePluginDestinationDirectoryURL = URL(fileURLWithPath: userPluginsPath)
        self.copyTempDirectoryURL = copyTempDirectoryURL

        // TODO: This is a hack that assures the `userPluginsPath` exsits
        // and is a directory. Really this should work like this:
        //
        // 1. If the directory does not exist, then it is ignored here
        //
        // 2. When trying to create a new plugin in the `userPluginsPath`,
        // we should first confirm that it exists, create it if it doesn't
        // and throw an error if it's not a directory. Then we'd create the
        // watcher at that time as well.
        //
        // That would also obviously need tests.
        //
        // Actually, the above has problems to. If the user then creates
        // the directory themselves it won't be watched, e.g., it won't
        // register if they create a plugin in the directory for example.
        do {
            try FileManagerHelper.createDirectoryIfMissing(atPath: userPluginsPath)
        } catch {
            assert(false)
        }

        let paths = pluginsPaths + [builtInPluginsPath, userPluginsPath].compactMap { $0 }
        let pathsSet = Set(paths)
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

    // MARK: `PluginsDirectoryManagerDelegate`

    func pluginsDirectoryManager(_: PluginsDirectoryManager,
                                 pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: String) {
        if let oldPlugin = plugin(atPluginPath: pluginPath) {
            if let newPlugin = BasePlugin.makePlugin(path: pluginPath) {
                // If there is an existing plugin and a new plugin, remove the old plugin and add the new plugin
                if !oldPlugin.isEqual(to: newPlugin) {
                    remove(oldPlugin)
                    add(newPlugin)
                }
            }
        } else {
            // If there is only a new plugin, add it
            if let newPlugin = BasePlugin.makePlugin(path: pluginPath) {
                add(newPlugin)
            }
        }
    }

    func pluginsDirectoryManager(_: PluginsDirectoryManager,
                                 pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: String) {
        if let oldPlugin = plugin(atPluginPath: pluginPath) {
            remove(oldPlugin)
        }
    }

    // MARK: DuplicatePluginControllerDelegate

    func duplicatePluginController(_: DuplicatePluginController,
                                   uniquePluginNameFromName name: String,
                                   for plugin: BasePlugin) -> String? {
        return delegate?.pluginsDataController(self,
                                               uniquePluginNameFromName: name,
                                               for: plugin)
    }

    // MARK: Add & Remove Helpers

    func add(_ plugin: BasePlugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary[pluginPath] = plugin
        delegate?.pluginsDataController(self, didAddPlugin: plugin)
    }

    func remove(_ plugin: BasePlugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary.removeValue(forKey: pluginPath)
        delegate?.pluginsDataController(self, didRemovePlugin: plugin)
    }

    func plugin(atPluginPath pluginPath: String) -> BasePlugin? {
        return pluginPathToPluginDictionary[pluginPath]
    }

    // MARK: Duplicate and Remove

    func moveToTrash(_ plugin: BasePlugin, handler: ((_ url: URL?, _ error: Error?) -> Void)?) {
        assert(plugin.editable, "The plugin should be editable")
        let bundeURL = plugin.bundle.bundleURL
        NSWorkspace.shared.recycle([bundeURL]) { [weak self] dictionary, error in
            guard let strongSelf = self else {
                return
            }
            let trashURL = dictionary[bundeURL]
            if error == nil {
                strongSelf.remove(plugin)
                assert(trashURL != nil)
            }
            handler?(trashURL, error)
        }
    }

    func duplicate(_ plugin: BasePlugin,
                   handler: ((_ plugin: BasePlugin?, _ error: NSError?) -> Void)?) {
        do {
            try type(of: self).createDirectoryIfMissing(at: duplicatePluginDestinationDirectoryURL)
        } catch let error as NSError {
            handler?(nil, error)
            return
        }

        duplicatePluginController.duplicate(plugin,
                                            to: duplicatePluginDestinationDirectoryURL) { (plugin, error) -> Void in
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
        if exists, isDir.boolValue {
            return
        }

        if exists, !isDir.boolValue {
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

    var description: String {
        return "pluginDirectoryManagers = \(pluginDirectoryManagers)"
    }
}
