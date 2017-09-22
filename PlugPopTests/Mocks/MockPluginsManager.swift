//
//  MockPluginsManager.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

class MockPluginsManager: PluginsManager {
    var mockPluginsController: MockPluginsController {
        return pluginsController as! MockPluginsController
    }

    convenience init(pluginsPaths: [String],
                     copyTempDirectoryURL: URL,
                     defaults: DefaultsType,
                     userPluginsPath: String,
                     builtInPluginsPath: String?)
    {
        let types = PluginsManagerConfigurationTypes(defaultNewPluginManagerType: WCLDefaultNewPluginManager.self,
                                                     pluginsDataControllerType: PluginsDataController.self,
                                                     pluginsControllerType: MockPluginsController.self)
        let configuration = PluginsManagerConfiguration(types: types,
                                                        pluginsPaths: pluginsPaths,
                                                        copyTempDirectoryURL: copyTempDirectoryURL,
                                                        defaults: defaults,
                                                        userPluginsPath: userPluginsPath,
                                                        builtInPluginsPath: builtInPluginsPath)
        self.init(configuration: configuration)
    }
}
