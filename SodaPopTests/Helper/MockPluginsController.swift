//
//  MockPluginsController.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import SodaPop

class MockPluginsController: POPPluginsController {
    var overrideNameToPlugin = [String: BasePlugin]()

    func override(name: String, with plugin: BasePlugin) {
        overrideNameToPlugin[name] = plugin
    }

    override func plugin(withName name: String) -> BasePlugin? {
        if let plugin = overrideNameToPlugin[name] {
            return plugin
        }

        return super.plugin(withName: name)
    }
}
