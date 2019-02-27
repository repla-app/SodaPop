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
            userPluginsPath
        ]
    }

    public var builtInPluginsPath: String {
        return TestBundles.testPluginsDirectoryPath
    }

    public var userPluginsPath: String {
        return temporaryUserPluginsDirectoryPath
    }

    public lazy var defaultsSuiteName = {
        testMockUserDefaultsSuiteName
    }()

    public var defaults: DefaultsType {
        guard privateDefaults == nil else {
            return privateDefaults
        }
        privateDefaults = UserDefaults(suiteName: defaultsSuiteName)!
        return privateDefaults
    }

    private var privateDefaults: DefaultsType!

    open override func setUp() {
        super.setUp()
        guard let userDefaults = defaults as? UserDefaults else {
            XCTFail()
            return
        }
        userDefaults.removePersistentDomain(forName: defaultsSuiteName)
        XCTAssertNil(userDefaults.persistentDomain(forName: defaultsSuiteName))
        XCTAssertFalse(userDefaults.dictionaryRepresentation().keys.contains(defaultsSuiteName))
    }

    open override func tearDown() {
        super.tearDown()
        guard let userDefaults = defaults as? UserDefaults else {
            XCTFail()
            return
        }
        userDefaults.removePersistentDomain(forName: defaultsSuiteName)
        XCTAssertNil(userDefaults.persistentDomain(forName: defaultsSuiteName))
        XCTAssertFalse(userDefaults.dictionaryRepresentation().keys.contains(defaultsSuiteName))
        privateDefaults = nil
    }
}
