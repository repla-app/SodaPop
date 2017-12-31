//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/28/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

import PlugPop

open class PluginTestCase: PluginsManagerTestCase, PluginOwnerType {
    private var privatePlugin: Plugin!
    public var plugin: Plugin {
        return privatePlugin
    }

    override open func setUp() {
        super.setUp()

        // Set the plugin
        privatePlugin = pluginsManager.plugin(withName: testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        privatePlugin.isDefaultNewPlugin = true
    }
    
    override open func tearDown() {
        privatePlugin.isDefaultNewPlugin = false
        privatePlugin = nil
        super.tearDown()
    }

}
