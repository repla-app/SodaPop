//
//  PluginMaker.swift
//  SodaPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

class PluginMaker {
    let builtInPluginsPath: String?
    let userPluginsPath: String?
    let defaultNewPluginManager: POPDefaultNewPluginManager
    var pluginsController: POPPluginsController?

    init(defaultNewPluginManager: POPDefaultNewPluginManager,
         userPluginsPath: String?,
         builtInPluginsPath: String?) {
        self.defaultNewPluginManager = defaultNewPluginManager
        self.builtInPluginsPath = builtInPluginsPath
        self.userPluginsPath = userPluginsPath
    }

    func makePlugin(path: String) -> Plugin? {
        let pluginKind = self.pluginKind(for: path)
        guard let plugin = Plugin.makePlugin(path: path, pluginKind: pluginKind) else {
            return nil
        }
        plugin.uniqueNameDataSource = pluginsController
        plugin.defaultPluginDataSource = defaultNewPluginManager
        return plugin
    }

    func makePlugin(url: URL) -> Plugin? {
        return makePlugin(path: url.path)
    }

    // MARK: Private

    private func pluginKind(for path: String) -> PluginKind {
        let pluginContainerDirectory = path.deletingLastPathComponent
        switch pluginContainerDirectory {
        case let path where path == userPluginsPath:
            return PluginKind.user
        case let path where path == builtInPluginsPath:
            return PluginKind.builtIn
        default:
            return PluginKind.other
        }
    }
}
