//
//  MockPluginsManager.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import PlainBagel
@testable import PlugPop

class MockPluginsManager: PluginsManager {
    var mockPluginsController: MockPluginsController {
        guard let mockPluginsController = pluginsController as? MockPluginsController else {
            assert(false)
            abort()
        }
        return mockPluginsController
    }

    override class func makeConfiguration(pluginsPaths: [String],
                                          copyTempDirectoryURL: URL,
                                          defaults: DefaultsType,
                                          fallbackDefaultNewPluginName: String,
                                          userPluginsPath: String,
                                          builtInPluginsPath: String?) -> PluginsManagerConfiguration {
        let types = PluginsManagerConfigurationTypes(defaultNewPluginManagerType: POPDefaultNewPluginManager.self,
                                                     pluginsDataControllerType: PluginsDataController.self,
                                                     pluginsControllerType: MockPluginsController.self)
        return PluginsManagerConfiguration(types: types,
                                           pluginsPaths: pluginsPaths,
                                           copyTempDirectoryURL: copyTempDirectoryURL,
                                           defaults: defaults,
                                           fallbackDefaultNewPluginName: fallbackDefaultNewPluginName,
                                           userPluginsPath: userPluginsPath,
                                           builtInPluginsPath: builtInPluginsPath)
    }
}
