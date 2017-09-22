//
//  MockPluginsManager.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 9/20/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

class MockPluginsManger: PluginsManager {
    var mockPluginsController: MockPluginsController {
        return pluginsController as! MockPluginsController
    }
}
