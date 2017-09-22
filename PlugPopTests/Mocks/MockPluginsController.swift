//
//  MockPluginsController.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

class MockPluginsController: WCLPluginsController {
    var overrideNameToPlugin = [String: Plugin]()

    func override(name: String, with plugin: Plugin) {
        overrideNameToPlugin[name] = plugin
    }

    override func plugin(withName name: String) -> Plugin? {
        if let plugin = overrideNameToPlugin[name] {
            return plugin
        }

        return super.plugin(withName: name)
    }
}
