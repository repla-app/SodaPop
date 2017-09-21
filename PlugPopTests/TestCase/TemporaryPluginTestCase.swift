//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/27/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

@testable import PlugPop
import PotionTaster

class TemporaryPluginTestCase: TemporaryPluginsManagerTestCase {
    var plugin: Plugin!

    override func setUp() {
        super.setUp()

        // Set the plugin
        plugin = pluginsManager.plugin(withName: PotionTaster.testPluginName)
        plugin.editable = true
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        plugin.isDefaultNewPlugin = true
    }
    
    override func tearDown() {
        plugin.isDefaultNewPlugin = false
        plugin = nil
        super.tearDown()
    }
}
