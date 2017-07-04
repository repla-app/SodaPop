//
//  TestConstants.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

let defaultTimeout = 20.0

@testable import PlugPop

// MARK: Directories

let testTrashDirectoryPath = NSSearchPathForDirectoriesInDomains(.trashDirectory, .userDomainMask, true)[0]
let testTrashDirectoryURL = URL(fileURLWithPath: testTrashDirectoryPath)
let testPluginsDirectoryPathComponent = "PlugIns"

// MARK: Extensions

let testPluginSuffix = "html"
let testPluginSuffixes: [String] = [testPluginSuffix]
let testPluginSuffixesTwo: [String] = ["html", "md", "js"]
let testPluginSuffixesEmpty = [String]()

// MARK: `UserDefaults`

let testMockUserDefaultsSuiteName = "com.1percenter.PlugPopTests"

// MARK: KVO Keys

let testPluginDefaultNewPluginKeyPath = "defaultNewPlugin"

// MARK: Plugin Paths

let testMissingFilePathComponent = "None"
let testSlashPathComponent = "/"
let testPluginInfoDictionaryPathComponent = testPluginContentsDirectoryName + testSlashPathComponent + testPluginInfoDictionaryFilename
let testPluginContentsDirectoryName = "Contents"
let testPluginResourcesDirectoryName = "Resources"
let testPluginInfoDictionaryFilename = "Info.plist"

// MARK: Directories & Files

let testPluginDirectoryName = DuplicatePluginController.pluginFilename(fromName: testDirectoryName)
let testPluginDirectoryNameTwo = DuplicatePluginController.pluginFilename(fromName: testDirectoryNameTwo)
let testDirectoryName = "test"
let testDirectoryNameTwo = "test2"
let testDirectoryNameThree = "test3"
let testDirectoryNameFour = "test4"
let testFilename = "test.txt"
let testFilenameTwo = "test2.txt"
let testFileContents = "test"
let testApplicationSupportDirectoryName = "Application Support"
let testAppName = "PlugPop"
let testCopyTempDirectoryName = "Duplicate Plugin"
let testHiddenDirectoryName = ".DS_Store"

// Miscellaneous 

let testSharedResourcePathComponent = "js/zepto.js"
