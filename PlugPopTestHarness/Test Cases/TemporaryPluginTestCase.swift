//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/27/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

import PlugPop

open class TemporaryPluginTestCase: TemporaryPluginsManagerTestCase, PluginOwnerType {
    var tempPlugin: Plugin!
    public var plugin: Plugin {
        return tempPlugin
    }

    override open func setUp() {
        super.setUp()

        // Set the plugin
        tempPlugin = tempPluginsManager.plugin(withName: testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        XCTAssertTrue(isTemporaryItem(at: plugin.resourceURL!))
        tempPlugin.editable = true
        tempPlugin.isDefaultNewPlugin = true
    }
    
    override open func tearDown() {
        tempPlugin.isDefaultNewPlugin = false
        tempPlugin = nil
        super.tearDown()
    }
}
