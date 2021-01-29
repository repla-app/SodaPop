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
    var tempPlugins: [Plugin] {
        return [tempXMLPlugin, tempJSONPlugin]
    }
    var tempXMLPlugin: Plugin!
    var tempJSONPlugin: Plugin!
    
    open override func setUp() {
        super.setUp()
    }
    
    open override func tearDown() {
        super.tearDown()
    }
}
