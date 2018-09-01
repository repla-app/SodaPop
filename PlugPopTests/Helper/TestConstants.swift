//
//  TestConstants.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 12/29/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

let defaultTimeout = 20.0

// MARK: KVO Keys

let testPluginDefaultNewPluginKeyPath = "defaultNewPlugin"

// MARK: Plugin Paths

let testMissingFilePathComponent = "None"
let testSlashPathComponent = "/"
let testPluginInfoDictionaryPathComponent = testPluginContentsDirectoryName +
    testSlashPathComponent +
    testPluginInfoDictionaryFilename
let testPluginContentsDirectoryName = "Contents"
let testPluginResourcesDirectoryName = "Resources"
let testPluginInfoDictionaryFilename = "Info.plist"

// MARK: Directories & Files

let testDirectoryName = "test"
let testDirectoryNameTwo = "test2"
let testDirectoryNameThree = "test3"
let testDirectoryNameFour = "test4"
let testFilename = "test.txt"
let testFilenameTwo = "test2.txt"
let testFileContents = "test"
let testHiddenDirectoryName = ".DS_Store"

// Miscellaneous

let testSharedResourcePathComponent = "js/zepto.js"
