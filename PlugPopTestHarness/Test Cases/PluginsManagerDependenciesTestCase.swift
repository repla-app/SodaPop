//
//  PluginsManagerDependenciesTestCase.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/24/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import PlainBagel
import PlugPop
import SodaTaster
import XCTest
import XCTestTemp

open class PluginsManagerDependenciesTestCase: TemporaryDirectoryTestCase, PluginsManagerFactoryType {
    public var pluginsManagerType = PluginsManager.self
    public var pluginsDirectoryPaths: [String] {
        return [
            builtInPluginsPath,
            TestBundles.rootTestBundlePluginsDirectoryPath,
            userPluginsPath
        ]
    }

    public var builtInPluginsPath: String {
        return TestBundles.rootPluginsDirectoryPath
    }

    public var userPluginsPath: String {
        return temporaryUserPluginsDirectoryPath
    }

    public lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()

    open override func setUp() {
        super.setUp()
        guard let userDefaults = defaults as? UserDefaults else {
            XCTFail()
            return
        }
        userDefaults.removePersistentDomain(forName: testMockUserDefaultsSuiteName)
        XCTAssertNil(userDefaults.persistentDomain(forName: testMockUserDefaultsSuiteName))
    }

    open override func tearDown() {
        super.tearDown()
        guard let userDefaults = defaults as? UserDefaults else {
            XCTFail()
            return
        }
        userDefaults.removePersistentDomain(forName: testMockUserDefaultsSuiteName)
        XCTAssertNil(userDefaults.persistentDomain(forName: testMockUserDefaultsSuiteName))
    }
}
