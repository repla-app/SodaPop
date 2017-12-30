//
//  PluginsManagerDependenciesTestCase.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/24/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import XCTestTemp
import PotionTaster
@testable import PlugPop

open class PluginsManagerDependenciesTestCase: TemporaryDirectoryTestCase, PluginsManagerFactoryType {
    var pluginsManagerType = PluginsManager.self
    public var pluginsDirectoryPaths: [String] {
        return [builtInPluginsPath,
                PotionTaster.sharedTestResourcesPluginsDirectoryPath,
                userPluginsPath]
    }
    public var builtInPluginsPath: String {
        return PotionTaster.rootPluginsDirectoryPath
    }
    public var userPluginsPath: String {
        return temporaryUserPluginsDirectoryPath
    }
    public lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()
}
