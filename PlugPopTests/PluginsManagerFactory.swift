//
//  PluginsManagerFactory.swift
//  PlugPop
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

@testable import PlugPop

class PluginsManagerFactory {
    var pluginsDirectoryPaths: [String] {
        return [builtInPluginsPath, sharedTestResourcesPluginsPath]
    }
    var sharedTestResourcesPluginsPath: String {
        return PotionTaster.sharedTestResourcesPluginsDirectoryPath
    }
    var builtInPluginsPath: String {
        return PotionTaster.rootPluginsDirectoryPath
    }
    lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()
    var pluginsManagerType = PluginsManager.self

    func makePluginsManager() -> PluginsManager {
        return pluginsManagerType(paths: pluginsDirectoryPaths,
                                  duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL,
                                  copyTempDirectoryURL: cachesURL,
                                  defaults: defaults,
                                  builtInPluginsPath: builtInPluginsPath,
                                  applicationSupportPluginsPath: nil)
    }
}
