//
//  DefaultsTestCase.swift
//  PlugPop
//
//  Created by Roben Kleene on 6/14/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

protocol DefaultsTestCase {
    var defaults: DefaultsType { get }
}
