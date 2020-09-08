//
//  PluginsManagerTests.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 9/8/20.
//  Copyright © 2020 Roben Kleene. All rights reserved.
//

import XCTest
@testable import SodaPop
import SodaPopTestHarness

class PluginsManagerTests: PluginsManagerTestCase {
    func testMultiplePluginsDirectories() {
        guard let plugin = pluginsManager.plugin(withName: testPluginNameTestNode) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(plugin)
        XCTAssertEqual(testPluginCommandTestNode, plugin.command)
    }
}
