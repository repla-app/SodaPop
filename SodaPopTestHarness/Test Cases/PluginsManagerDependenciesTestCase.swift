//
//  PluginsManagerDependenciesTestCase.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 9/24/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import PlainBagel
import SodaFountain
import SodaPop
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
        return TestPlugins.testPluginsDirectoryPath
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

    override open func setUp() {
        super.setUp()
        guard let userDefaults = defaults as? UserDefaults else {
            XCTFail()
            return
        }
        userDefaults.removePersistentDomain(forName: defaultsSuiteName)
        XCTAssertNil(userDefaults.persistentDomain(forName: defaultsSuiteName))
        XCTAssertFalse(userDefaults.dictionaryRepresentation().keys.contains(defaultsSuiteName))
    }

    override open func tearDown() {
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
