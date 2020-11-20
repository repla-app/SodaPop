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

extension PluginsManagerOwnerType where Self: XCTestCase {
    public func newPluginWithConfirmation() -> BasePlugin {
        var createdPlugin: BasePlugin!
        let createdPluginExpectation = expectation(description: "Create new plugin")
        pluginsManager.newPlugin { (newPlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        return createdPlugin
    }

    public func duplicateWithConfirmation(_ plugin: BasePlugin) -> BasePlugin {
        var createdPlugin: BasePlugin!
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
