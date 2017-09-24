//
//  TemporaryPluginsManagerTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

@testable import PlugPop
import PotionTaster
import XCTest

class TemporaryPluginsManagerTestCase: TemporaryPluginsManagerDependenciesTestCase {

    var tempPluginsManager: PluginsManager!

    override func setUp() {
        super.setUp()
        tempPluginsManager = makePluginsManager()
    }
}
