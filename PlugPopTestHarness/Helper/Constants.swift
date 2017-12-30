//
//  TestConstants.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

@testable import PlugPop
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
public let testPluginName = PotionTaster.testPluginNameIRB
public let testPluginNameTwo = PotionTaster.testPluginNameHTML
public let testPluginExtension = PotionTaster.testPluginFileExtension
public let testPluginCommand = PotionTaster.testPluginCommandIRB
public let testPluginCommandTwo = PotionTaster.testPluginCommandHTML
public let testPluginNameNotDefault = PotionTaster.testPluginNameIRB
public let testPluginCommandNotDefault = PotionTaster.testPluginCommandIRB
public let testPluginDirectoryName = DuplicatePluginController.pluginFilename(fromName: testPluginName)
public let testPluginDirectoryNameTwo = DuplicatePluginController.pluginFilename(fromName: testPluginNameTwo)
public let testPluginDirectoryNoPluginName = DuplicatePluginController.pluginFilename(fromName: "No Plugin")
public let testPluginNameNonexistent = PotionTaster.testPluginNameNonexistent
public let testPluginNameHelloWorld = PotionTaster.testPluginNameHelloWorld
public let testPluginNameLog = PotionTaster.testPluginNameTestLog
public let testPluginNamePrint = PotionTaster.testPluginNamePrint

// MARK: Directories & Files

public let testApplicationSupportDirectoryName = "Application Support"
public let testAppName = "PlugPop"
public let testCopyTempDirectoryName = "Duplicate Plugin"
