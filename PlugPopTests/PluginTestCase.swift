//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/28/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

@testable import PlugPop
import PotionTaster

class PluginTestCase: PluginsManagerTestCase {
    var plugin: Plugin!
    var pluginURL: URL {
        return plugin.bundle.bundleURL
    }
    var pluginPath: String {
        return pluginURL.path
    }

    override func setUp() {
        super.setUp()

        // Set the plugin
        plugin = pluginsManager.plugin(withName: PotionTaster.testPluginNameTwo) // `testPluginNameTwo` is `IRB` it's significantly smaller than `HTML`, some of tests copy the plugin, so smaller is better.
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        plugin.isDefaultNewPlugin = true
    }
    
    override func tearDown() {
        plugin.isDefaultNewPlugin = false
        plugin = nil
        super.tearDown()
    }

}
