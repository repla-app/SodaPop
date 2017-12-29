//
//  PluginDataEventManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/9/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop
import PlugPopTestHarness

class TemporaryPluginsDataControllerEventTestCase: TemporaryPluginTestCase {
    var pluginDataEventManager: PluginDataEventManager!
    
    override func setUp() {
        super.setUp()
        pluginDataEventManager = PluginDataEventManager()
        pluginDataEventManager.delegate = tempPluginsManager
        tempPluginsManager.pluginsDataController.delegate = pluginDataEventManager
    }
    
    override func tearDown() {
        tempPluginsManager.pluginsDataController.delegate = tempPluginsManager
        pluginDataEventManager.delegate = nil
        pluginDataEventManager = nil
        super.tearDown()
    }
}
