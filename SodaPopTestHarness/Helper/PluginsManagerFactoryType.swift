//
//  PluginsManagerFactory.swift
//  SodaPop
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import PlainBagel
import SodaPop
import XCTestTemp

extension TemporaryDirectoryTestCase: TemporaryDirectoryType {}
extension UserDefaults: DefaultsType {}

public protocol TemporaryDirectoryType {
    var temporaryDirectoryURL: URL! { get }
    var temporaryDirectoryPath: String! { get }
}

public protocol TempUserPluginsDirectoryType: TemporaryDirectoryType {
    var temporaryApplicationSupportDirectoryURL: URL { get }
    var temporaryApplicationSupportDirectoryPath: String { get }
    var temporaryUserPluginsDirectoryURL: URL { get }
    var temporaryUserPluginsDirectoryPath: String { get }
}

public extension TempUserPluginsDirectoryType {
    var temporaryApplicationSupportDirectoryURL: URL {
        return temporaryDirectoryURL
            .appendingPathComponent(testApplicationSupportDirectoryName)
    }

    var temporaryApplicationSupportDirectoryPath: String {
        return temporaryApplicationSupportDirectoryURL.path
    }

    var fallbackDefaultNewPluginName: String {
        return testPluginNameDefault
    }

    var temporaryUserPluginsDirectoryURL: URL {
        return temporaryApplicationSupportDirectoryURL
            .appendingPathComponent(testAppName)
            .appendingPathComponent(testPluginsDirectoryPathComponent)
    }

    var temporaryUserPluginsDirectoryPath: String {
        return temporaryUserPluginsDirectoryURL.path
    }
}

public protocol TempCopyTempURLType: TemporaryDirectoryType {
    var tempCopyTempDirectoryURL: URL { get }
}

public extension TempCopyTempURLType {
    var tempCopyTempDirectoryURL: URL {
        return temporaryDirectoryURL
            .appendingPathComponent(testCopyTempDirectoryName)
    }
}

public protocol PluginsManagerDependenciesType: TempCopyTempURLType, TempUserPluginsDirectoryType {
    var pluginsDirectoryPaths: [String] { get }
    var copyTempDirectoryURL: URL { get }
    var defaults: DefaultsType { get } // Must be supplied by the `superclass`
    var fallbackDefaultNewPluginName: String { get }
    var userPluginsPath: String { get }
    var builtInPluginsPath: String { get }
}

public extension PluginsManagerDependenciesType {
    var copyTempDirectoryURL: URL {
        return tempCopyTempDirectoryURL
    }

    var userPluginsURL: URL {
        return URL(fileURLWithPath: userPluginsPath)
    }

    var builtInPluginsURL: URL {
        return URL(fileURLWithPath: builtInPluginsPath)
    }
}

public protocol PluginsManagerFactoryType: PluginsManagerDependenciesType {
    var pluginsManagerType: PluginsManager.Type { get }
    func makePluginsManager() -> PluginsManager
}

public extension PluginsManagerFactoryType {
    func makePluginsManager() -> PluginsManager {
        let configuration = pluginsManagerType.makeConfiguration(pluginsPaths: pluginsDirectoryPaths,
                                                                 copyTempDirectoryURL: copyTempDirectoryURL,
                                                                 defaults: defaults,
                                                                 fallbackDefaultNewPluginName:
                                                                 fallbackDefaultNewPluginName,
                                                                 userPluginsPath: userPluginsPath,
                                                                 builtInPluginsPath: builtInPluginsPath)
        let pluginsManager = pluginsManagerType.init(configuration: configuration)

        return pluginsManager
    }
}
