//
//  TemporaryAndCachesTestCase.swift
//  PlugPop
//
//  Created by Roben Kleene on 5/31/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import XCTestTemp

class TemporaryCachesTestCase: TemporaryDirectoryTestCase {
    lazy var cachesPath: String = {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return cachesDirectory.appendingPathComponent(String(describing: self))
    }()
    lazy var cachesURL: URL = {
        URL(fileURLWithPath: self.cachesPath)
    }()
}
