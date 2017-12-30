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

open class TemporaryPluginsDataControllerEventTestCase: TemporaryPluginTestCase {
    var pluginDataEventManager: PluginDataEventManager!
    
    override open func setUp() {
        super.setUp()
        pluginDataEventManager = PluginDataEventManager()
        pluginDataEventManager.delegate = tempPluginsManager
        tempPluginsManager.pluginsDataController.delegate = pluginDataEventManager
    }
    
    override open func tearDown() {
        tempPluginsManager.pluginsDataController.delegate = tempPluginsManager
        pluginDataEventManager.delegate = nil
        pluginDataEventManager = nil
        super.tearDown()
    }
}
