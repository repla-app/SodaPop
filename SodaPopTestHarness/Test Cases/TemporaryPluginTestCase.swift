//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/27/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import SodaPop
import XCTest

open class TemporaryPluginTestCase: TemporaryPluginsManagerTestCase, PluginOwnerType {
    var tempPlugin: Plugin!
    public var plugin: Plugin {
        return tempPlugin
    }

    open override func setUp() {
        super.setUp()

        // Set the plugin
        tempPlugin = tempPluginsManager.plugin(withName: testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        XCTAssertTrue(isTemporaryItem(at: plugin.resourceURL!))
        tempPlugin.editable = true
        tempPlugin.isDefaultNewPlugin = true
    }

    open override func tearDown() {
        tempPlugin.isDefaultNewPlugin = false
        tempPlugin = nil
        super.tearDown()
    }
}
