//
//  PluginsManagerDependenciesTestCase.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/24/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

class TemporaryPluginsManagerDependenciesTestCase: TemporaryPluginsTestCase, PluginsManagerFactoryType {
    var pluginsManagerType = PluginsManager.self
    var pluginsDirectoryPaths: [String] {
        return [userPluginsPath, builtInPluginsPath]
    }
    var builtInPluginsPath: String {
        return temporaryUserPluginsDirectoryPath
    }
    var userPluginsPath: String {
        return tempPluginsDirectoryPath
    }
    lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()
}
