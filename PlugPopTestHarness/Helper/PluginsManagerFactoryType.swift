//
//  PluginsManagerFactory.swift
//  PlugPop
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import PlainBagel
import PlugPop
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

extension TempUserPluginsDirectoryType {
    public var temporaryApplicationSupportDirectoryURL: URL {
        return temporaryDirectoryURL
            .appendingPathComponent(testApplicationSupportDirectoryName)
    }

    public var temporaryApplicationSupportDirectoryPath: String {
        return temporaryApplicationSupportDirectoryURL.path
    }

    public var temporaryUserPluginsDirectoryURL: URL {
        return temporaryApplicationSupportDirectoryURL
            .appendingPathComponent(testAppName)
            .appendingPathComponent(testPluginsDirectoryPathComponent)
    }

    public var temporaryUserPluginsDirectoryPath: String {
        return temporaryUserPluginsDirectoryURL.path
    }
}

public protocol TempCopyTempURLType: TemporaryDirectoryType {
    var tempCopyTempDirectoryURL: URL { get }
}

extension TempCopyTempURLType {
    public var tempCopyTempDirectoryURL: URL {
        return temporaryDirectoryURL
            .appendingPathComponent(testCopyTempDirectoryName)
    }
}

public protocol PluginsManagerDependenciesType: TempCopyTempURLType, TempUserPluginsDirectoryType {
    var pluginsDirectoryPaths: [String] { get }
    var copyTempDirectoryURL: URL { get }
    var defaults: DefaultsType { get } // Must be supplied by the `superclass`
    var userPluginsPath: String { get }
    var builtInPluginsPath: String { get }
}

extension PluginsManagerDependenciesType {
    public var copyTempDirectoryURL: URL {
        return tempCopyTempDirectoryURL
    }

    public var userPluginsURL: URL {
        return URL(fileURLWithPath: userPluginsPath)
    }

    public var builtInPluginsURL: URL {
        return URL(fileURLWithPath: builtInPluginsPath)
    }
}

public protocol PluginsManagerFactoryType: PluginsManagerDependenciesType {
    var pluginsManagerType: PluginsManager.Type { get }
    func makePluginsManager() -> PluginsManager
}

extension PluginsManagerFactoryType {
    public func makePluginsManager() -> PluginsManager {
        let configuration = pluginsManagerType.self.makeConfiguration(pluginsPaths: pluginsDirectoryPaths,
                                                                      copyTempDirectoryURL: copyTempDirectoryURL,
                                                                      defaults: defaults,
                                                                      userPluginsPath: userPluginsPath,
                                                                      builtInPluginsPath: builtInPluginsPath)
        let pluginsManager = pluginsManagerType.init(configuration: configuration)

        return pluginsManager
    }
}
