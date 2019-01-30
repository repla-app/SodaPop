//
//  TestConstants.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import PlugPop
import SodaTaster

// MARK: Directories

public let testTrashDirectoryPath = NSSearchPathForDirectoriesInDomains(.trashDirectory, .userDomainMask, true)[0]
public let testTrashDirectoryURL = URL(fileURLWithPath: testTrashDirectoryPath)
public let testPluginsDirectoryPathComponent = "PlugIns"

// MARK: Extensions

public let testPluginSuffix = "html"
public let testPluginSuffixes: [String] = [testPluginSuffix]
public let testPluginSuffixesTwo: [String] = ["html", "md", "js"]
public let testPluginSuffixesEmpty = [String]()

// MARK: `SodaTaster`

// `IRB` is significantly smaller than `HTML`, some of tests copy the plugin,
// so smaller is better.
public let testPluginFileExtension = "wcplugin"
public let testPluginName = TestBundles.testPluginNameIRB
public let testPluginNameTwo = TestBundles.testPluginNameHTML
public let testPluginExtension = TestBundles.testPluginFileExtension
public let testPluginCommand = TestBundles.testPluginCommandIRB
public let testPluginCommandTwo = TestBundles.testPluginCommandHTML
public let testPluginNameNotDefault = TestBundles.testPluginNameIRB
public let testPluginCommandNotDefault = TestBundles.testPluginCommandIRB
public let testPluginDirectoryName = testPluginName.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNameTwo = testPluginNameTwo.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNoPluginName = "No Plugin".appendingPathExtension(testPluginFileExtension)!
public let testPluginNameNonexistent = TestBundles.testPluginNameNonexistent
public let testPluginNameHelloWorld = TestBundles.testPluginNameHelloWorld
public let testPluginNameCat = TestBundles.testPluginNameCat
public let testPluginNameLog = TestBundles.testPluginNameTestLog
public let testPluginNamePrint = TestBundles.testPluginNamePrint

// MARK: Directories & Files

public let testApplicationSupportDirectoryName = "Application Support"
public let testAppName = "PlugPop"
public let testCopyTempDirectoryName = "Duplicate Plugin Tests"
