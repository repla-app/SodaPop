//
//  PluginsManagerConfiguration.swift
//  PlugPop
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

struct PluginsManagerConfigurationTypes {
    let defaultNewPluginManagerType: WCLDefaultNewPluginManager.Type
    let pluginsDataControllerType: PluginsDataController.Type
    let pluginsControllerType: WCLPluginsController.Type
    static func makeDefault() -> PluginsManagerConfigurationTypes {
        return self.init(defaultNewPluginManagerType: WCLDefaultNewPluginManager.self,
                         pluginsDataControllerType: PluginsDataController.self,
                         pluginsControllerType: WCLPluginsController.self)
    }
}

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
        self.init(types: PluginsManagerConfigurationTypes.makeDefault(),
                  pluginsPaths: pluginsPaths,
                  copyTempDirectoryURL: copyTempDirectoryURL,
                  defaults: defaults,
                  userPluginsPath: userPluginsPath,
                  builtInPluginsPath: builtInPluginsPath)
    }

    required init(types: PluginsManagerConfigurationTypes,
                  pluginsPaths: [String],
                  copyTempDirectoryURL: URL,
                  defaults: DefaultsType,
                  userPluginsPath: String,
                  builtInPluginsPath: String?)
    {
        let defaultNewPluginManager = types.defaultNewPluginManagerType.init(defaults: defaults)
        let pluginsDataController = types.pluginsDataControllerType.init(pluginsPaths: pluginsPaths,
                                                                         copyTempDirectoryURL: copyTempDirectoryURL,
                                                                         defaultNewPluginManager: defaultNewPluginManager,
                                                                         userPluginsPath: userPluginsPath,
                                                                         builtInPluginsPath: builtInPluginsPath)
        let pluginsController = types.pluginsControllerType.init(plugins: pluginsDataController.plugins)
        self.defaultNewPluginManager = defaultNewPluginManager
        self.pluginsDataController = pluginsDataController
        self.pluginsController = pluginsController
    }
}
