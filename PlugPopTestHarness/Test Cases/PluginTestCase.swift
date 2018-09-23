//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/28/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import PlugPop
import XCTest

open class PluginTestCase: PluginsManagerTestCase, PluginOwnerType {
    private var privatePlugin: Plugin!
    public var plugin: Plugin {
        return privatePlugin
    }

    open override func setUp() {
        super.setUp()

        // Set the plugin
        privatePlugin = pluginsManager.plugin(withName: testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        privatePlugin.isDefaultNewPlugin = true
    }

    open override func tearDown() {
        privatePlugin.isDefaultNewPlugin = false
        privatePlugin = nil
        super.tearDown()
    }
}
