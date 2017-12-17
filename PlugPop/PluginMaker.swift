//
//  PluginMaker.swift
//  PlugPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

class PluginMaker {

    let builtInPluginsPath: String?
    let userPluginsPath: String?
    let defaultNewPluginManager: POPDefaultNewPluginManager
    
    init(defaultNewPluginManager: POPDefaultNewPluginManager,
         userPluginsPath: String?,
         builtInPluginsPath: String?)
    {
        self.defaultNewPluginManager = defaultNewPluginManager
        self.builtInPluginsPath = builtInPluginsPath
        self.userPluginsPath = userPluginsPath
    }

    func makePlugin(path: String) -> Plugin? {
        let pluginType = self.pluginType(for: path)
        guard let plugin = Plugin.makePlugin(path: path, pluginType: pluginType) else {
            return nil
        }
        plugin.dataSource = defaultNewPluginManager
        return plugin
    }
    
    func makePlugin(url: URL) -> Plugin? {
        return makePlugin(path: url.path)
    }

    // MARK: Private

    private func pluginType(for path: String) -> PluginType {
        let pluginContainerDirectory = path.deletingLastPathComponent
        switch pluginContainerDirectory {
        case let path where path == userPluginsPath:
            return PluginType.user
        case let path where path == builtInPluginsPath:
            return PluginType.builtIn
        default:
            return PluginType.other
        }
    }

}
