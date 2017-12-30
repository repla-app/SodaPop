//
//  PluginsManagerDependenciesTestCase.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/24/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

open class TemporaryPluginsManagerDependenciesTestCase: TemporaryPluginsTestCase, PluginsManagerFactoryType {
    var pluginsManagerType = PluginsManager.self
    public var pluginsDirectoryPaths: [String] {
        return [userPluginsPath, builtInPluginsPath]
    }
    public var builtInPluginsPath: String {
        return tempPluginsDirectoryPath
    }
    public var userPluginsPath: String {
        return temporaryUserPluginsDirectoryPath
    }
    public lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()
}
