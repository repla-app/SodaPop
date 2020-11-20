//
//  PluginTestCaseType.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 12/9/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import SodaPop

public protocol PluginOwnerType: PluginsManagerOwnerType {
    var plugin: Plugin { get }
}
