//
//  PluginsManagerConfiguration.swift
//  SodaPop
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import PlainBagel

public struct PluginsManagerConfigurationTypes {
    let defaultNewPluginManagerType: POPDefaultNewPluginManager.Type
    let pluginsDataControllerType: PluginsDataController.Type
    let pluginsControllerType: POPPluginsController.Type
    static func makeDefault() -> PluginsManagerConfigurationTypes {
        return self.init(defaultNewPluginManagerType: POPDefaultNewPluginManager.self,
                         pluginsDataControllerType: PluginsDataController.self,
                         pluginsControllerType: POPPluginsController.self)
    }
}

public class PluginsManagerConfiguration {
    let defaultNewPluginManager: POPDefaultNewPluginManager
    let pluginsDataController: PluginsDataController
    let pluginsController: POPPluginsController

    public convenience init(pluginsPaths: [String],
                            copyTempDirectoryURL: URL,
                            defaults: DefaultsType,
                            fallbackDefaultNewPluginName: String,
                            userPluginsPath: String,
                            builtInPluginsPath: String?) {
        self.init(types: PluginsManagerConfigurationTypes.makeDefault(),
                  pluginsPaths: pluginsPaths,
                  copyTempDirectoryURL: copyTempDirectoryURL,
                  defaults: defaults,
                  fallbackDefaultNewPluginName: fallbackDefaultNewPluginName,
                  userPluginsPath: userPluginsPath,
                  builtInPluginsPath: builtInPluginsPath)
    }

    public required init(types: PluginsManagerConfigurationTypes,
                         pluginsPaths: [String],
                         copyTempDirectoryURL: URL,
                         defaults: DefaultsType,
                         fallbackDefaultNewPluginName: String,
                         userPluginsPath: String,
                         builtInPluginsPath: String?) {
        let defaultNewPluginManager = types.defaultNewPluginManagerType.init(defaults: defaults,
                                                                             fallbackDefaultNewPluginName:
                                                                             fallbackDefaultNewPluginName)
        let pluginsDataController = types.pluginsDataControllerType.init(pluginsPaths: pluginsPaths,
                                                                         copyTempDirectoryURL: copyTempDirectoryURL,
                                                                         defaultNewPluginManager:
                                                                         defaultNewPluginManager,
                                                                         userPluginsPath: userPluginsPath,
                                                                         builtInPluginsPath: builtInPluginsPath)
        let pluginsController = types.pluginsControllerType.init(plugins: pluginsDataController.plugins)
        pluginsDataController.pluginsController = pluginsController
        self.defaultNewPluginManager = defaultNewPluginManager
        self.pluginsDataController = pluginsDataController
        self.pluginsController = pluginsController
    }
}
