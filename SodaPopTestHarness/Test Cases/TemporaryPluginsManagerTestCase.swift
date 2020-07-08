//
//  TemporaryPluginsManagerTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import SodaPop
import XCTest

open class TemporaryPluginsManagerTestCase: TemporaryPluginsManagerDependenciesTestCase, PluginsManagerOwnerType {
    var tempPluginsManager: PluginsManager!
    public var pluginsManager: PluginsManager {
        return tempPluginsManager
    }

    override open func setUp() {
        super.setUp()
        tempPluginsManager = makePluginsManager()
    }

    override open func tearDown() {
        tempPluginsManager = nil
        // Making a `pluginsManager` will implicitly create the
        // `userPluginsURL`. So that needs to be cleaned up here.
        do {
            try removeTemporaryItem(at: temporaryApplicationSupportDirectoryURL)
        } catch {
            XCTFail()
        }
        super.tearDown()
    }
}
