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
public let testPluginName = SodaTaster.testPluginNameIRB
public let testPluginNameTwo = SodaTaster.testPluginNameHTML
public let testPluginExtension = SodaTaster.testPluginFileExtension
public let testPluginCommand = SodaTaster.testPluginCommandIRB
public let testPluginCommandTwo = SodaTaster.testPluginCommandHTML
public let testPluginNameNotDefault = SodaTaster.testPluginNameIRB
public let testPluginCommandNotDefault = SodaTaster.testPluginCommandIRB
public let testPluginDirectoryName = testPluginName.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNameTwo = testPluginNameTwo.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNoPluginName = "No Plugin".appendingPathExtension(testPluginFileExtension)!
public let testPluginNameNonexistent = SodaTaster.testPluginNameNonexistent
public let testPluginNameHelloWorld = SodaTaster.testPluginNameHelloWorld
public let testPluginNameCat = SodaTaster.testPluginNameCat
public let testPluginNameLog = SodaTaster.testPluginNameTestLog
public let testPluginNamePrint = SodaTaster.testPluginNamePrint

// MARK: Directories & Files

public let testApplicationSupportDirectoryName = "Application Support"
public let testAppName = "PlugPop"
public let testCopyTempDirectoryName = "Duplicate Plugin Tests"
