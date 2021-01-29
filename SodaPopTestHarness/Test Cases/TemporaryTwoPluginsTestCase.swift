//
//  TemporaryTwoPluginsTestCase.swift
//  SodaPopTestHarness
//
//  Created by Roben Kleene on 1/29/21.
//  Copyright © 2021 Roben Kleene. All rights reserved.
//

import Foundation
import SodaFountain
import SodaPop
import XCTest
import XCTestTemp

open class TemporaryTwoPluginsTestCase: TemporaryPluginsTestCase {
    var tempPlugins: [URL] {
        return [tempXMLPluginURL, tempJSONPluginURL]
    }
    var tempXMLPluginURL: URL!
    var tempJSONPluginURL: URL!
    
    open override func setUp() {
        super.setUp()
        tempXMLPluginURL = tempPluginURL
        tempJSONPluginURL = makeDuplicatePlugin(fromPluginNamed: testPluginNameJSON)
    }
    
    open override func tearDown() {
        super.tearDown()
    }
}
