//
//  TestConstants.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import PlugPop
import PotionTaster

// MARK: Directories

public let testTrashDirectoryPath = NSSearchPathForDirectoriesInDomains(.trashDirectory, .userDomainMask, true)[0]
public let testTrashDirectoryURL = URL(fileURLWithPath: testTrashDirectoryPath)
public let testPluginsDirectoryPathComponent = "PlugIns"

// MARK: Extensions

public let testPluginSuffix = "html"
public let testPluginSuffixes: [String] = [testPluginSuffix]
public let testPluginSuffixesTwo: [String] = ["html", "md", "js"]
public let testPluginSuffixesEmpty = [String]()

// MARK: `PotionTaster`

// `IRB` is significantly smaller than `HTML`, some of tests copy the plugin,
// so smaller is better.
public let testPluginFileExtension = "wcplugin"
public let testPluginName = PotionTaster.testPluginNameIRB
public let testPluginNameTwo = PotionTaster.testPluginNameHTML
public let testPluginExtension = PotionTaster.testPluginFileExtension
public let testPluginCommand = PotionTaster.testPluginCommandIRB
public let testPluginCommandTwo = PotionTaster.testPluginCommandHTML
public let testPluginNameNotDefault = PotionTaster.testPluginNameIRB
public let testPluginCommandNotDefault = PotionTaster.testPluginCommandIRB
public let testPluginDirectoryName = testPluginName.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNameTwo = testPluginNameTwo.appendingPathExtension(testPluginFileExtension)!
public let testPluginDirectoryNoPluginName = "No Plugin".appendingPathExtension(testPluginFileExtension)!
public let testPluginNameNonexistent = PotionTaster.testPluginNameNonexistent
public let testPluginNameHelloWorld = PotionTaster.testPluginNameHelloWorld
public let testPluginNameCat = PotionTaster.testPluginNameCat
public let testPluginNameLog = PotionTaster.testPluginNameTestLog
public let testPluginNamePrint = PotionTaster.testPluginNamePrint

// MARK: Directories & Files

public let testApplicationSupportDirectoryName = "Application Support"
public let testAppName = "PlugPop"
public let testCopyTempDirectoryName = "Duplicate Plugin"
