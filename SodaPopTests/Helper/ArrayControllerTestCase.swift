//
//  ArrayControllerTestCase.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 3/28/19.
//  Copyright © 2019 Roben Kleene. All rights reserved.
//

import AppKit
import Foundation
@testable import SodaPop
import SodaPopTestHarness
import XCTest

class TemporaryArrayControllerTestCase: TemporaryPluginsDataControllerEventTestCase {
    var arrayController: NSArrayController!

    override func setUp() {
        super.setUp()
        arrayController = NSArrayController()
        arrayController.bind(NSBindingName(rawValue: "contentArray"),
                             to: pluginsManager.pluginsSource,
                             withKeyPath: "plugins",
                             options: nil)
    }

    override func tearDown() {
        guard let arrayControllerPlugins = arrayController.arrangedObjects as? [BasePlugin] else {
            XCTFail()
            return
        }
        let arrayControllerPluginsSet = Set(arrayControllerPlugins)
        let pluginsSourcePluginsSet = Set(pluginsManager.plugins)
        XCTAssertEqual(arrayControllerPluginsSet, pluginsSourcePluginsSet)
        super.tearDown()
    }
}

class ArrayControllerTestCase: PluginsManagerTestCase {
    var arrayController: NSArrayController!

    override func setUp() {
        super.setUp()
        arrayController = NSArrayController()
        arrayController.bind(NSBindingName(rawValue: "contentArray"),
                             to: pluginsManager.pluginsSource,
                             withKeyPath: "plugins",
                             options: nil)
    }

    override func tearDown() {
        guard let arrayControllerPlugins = arrayController.arrangedObjects as? [BasePlugin] else {
            XCTFail()
            return
        }
        let arrayControllerPluginsSet = Set(arrayControllerPlugins)
        let pluginsSourcePluginsSet = Set(pluginsManager.plugins)
        XCTAssertEqual(arrayControllerPluginsSet, pluginsSourcePluginsSet)
        super.tearDown()
    }
}
