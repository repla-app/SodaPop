//
//  PluginsManagerConfiguration.swift
//  PlugPop
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

class PluginsManagerConfiguration {
    let defaultNewPluginManager: WCLDefaultNewPluginManager
    let pluginsDataController: PluginsDataController
    let pluginsController: WCLPluginsController

    convenience init(pluginsPaths: [String],
         copyTempDirectoryURL: URL,
         defaults: DefaultsType,
         userPluginsPath: String,
         builtInPluginsPath: String?)
    {
        let defaultNewPluginManager = WCLDefaultNewPluginManager(defaults: defaults)
        let pluginsDataController = PluginsDataController(pluginsPaths: pluginsPaths,
                                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                                           defaultNewPluginManager: defaultNewPluginManager,
                                                           userPluginsPath: userPluginsPath,
                                                           builtInPluginsPath: builtInPluginsPath)
        let pluginsController = WCLPluginsController(plugins: pluginsDataController.plugins)
        self.init(defaultNewPluginManager: defaultNewPluginManager,
                  pluginsDataController: pluginsDataController,
                  pluginsController: pluginsController)
    }

    required init(defaultNewPluginManager: WCLDefaultNewPluginManager,
                  pluginsDataController: PluginsDataController,
                  pluginsController: WCLPluginsController)
    {
        self.defaultNewPluginManager = defaultNewPluginManager
        self.pluginsDataController = pluginsDataController
        self.pluginsController = pluginsController
    }
}
