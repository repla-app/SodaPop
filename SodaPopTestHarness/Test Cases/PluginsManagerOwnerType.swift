//
//  PluginsManagerTestCaseType.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 12/9/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import SodaPop
import XCTest

public protocol PluginsManagerOwnerType {
    var pluginsManager: PluginsManager { get }
}

public extension PluginsManagerOwnerType where Self: XCTestCase {
    func newPluginWithConfirmation() -> Plugin {
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectation(description: "Create new plugin")
        pluginsManager.newPlugin { (newPlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        return createdPlugin
    }

    func duplicateWithConfirmation(_ plugin: Plugin) -> Plugin {
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectation(description: "Create new plugin")
        pluginsManager.duplicate(plugin) { (newPlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        return createdPlugin
    }
}
