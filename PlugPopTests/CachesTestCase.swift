//
//  TemporaryAndCachesTestCase.swift
//  PlugPop
//
//  Created by Roben Kleene on 5/31/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

protocol CachesTestCase {
    var cachesPath: String { get }
    var cachesURL: URL { get }
}

extension CachesTestCase {
    var cachesPath: String {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return cachesDirectory.appendingPathComponent(String(describing: self))
    }
    var cachesURL: URL {
        return URL(fileURLWithPath: self.cachesPath)
    }
}
