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
    public var tempPluginURLs: [URL] {
        return [tempXMLPluginURL, tempJSONPluginURL]
    }

    public var tempXMLPluginURL: URL!
    public var tempJSONPluginURL: URL!

    override open func setUp() {
        super.setUp()
        tempXMLPluginURL = tempPluginURL
        tempJSONPluginURL = makeDuplicatePlugin(fromPluginNamed: testPluginNameJSON)
    }

    override open func tearDown() {
        tempXMLPluginURL = nil
        tempJSONPluginURL = nil
        super.tearDown()
    }
}
