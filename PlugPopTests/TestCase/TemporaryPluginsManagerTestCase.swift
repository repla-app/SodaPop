//
//  TemporaryPluginsManagerTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

@testable import PlugPop
import PotionTaster
import XCTest

class TemporaryPluginsManagerTestCase: TemporaryPluginsTestCase, PluginsManagerFactoryType {
    var builtInPluginsPath: String? = nil
    var userPluginsPath: String {
        return tempPluginsDirectoryPath
    }
    var pluginsDirectoryPaths: [String] {
        return [userPluginsPath]
    }
    var pluginsManager: PluginsManager!
    lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()

    override func setUp() {
        super.setUp()
        pluginsManager = makePluginsManager()
    }
}
