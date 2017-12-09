//
//  PluginTestCaseType.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 12/9/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

@testable import PlugPop

protocol PluginOwnerType: PluginsManagerOwnerType {
    var plugin: Plugin { get }
    var pluginURL: URL { get }
    var pluginPath: String { get }
}

