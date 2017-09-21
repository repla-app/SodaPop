//
//  MockPluginsManagerConfiguration.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

class MockPluginsManagerConfiguration: PluginsManagerConfiguration {
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
}
