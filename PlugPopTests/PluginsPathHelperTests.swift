//
//  PluginsPathHelper.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop

class PluginsPathHelperTestCase: TemporaryPluginsTestCase {
    func areEqual(_ range: NSRange, _ comparisonRange: NSRange) -> Bool {
        return range.location == comparisonRange.location && range.length == comparisonRange.length
    }
    
    // Tests normal paths, that paths with stray slashes behave identical
    func testPathsAndPathsWithSlashes() {
        
        let testPaths = [tempPluginPath!, tempPluginPath! + testSlashPathComponent]
        let testSubpaths = [tempPluginsDirectoryPath!, tempPluginsDirectoryPath + testSlashPathComponent]
        
        let testRange = PluginsPathHelper.subpathRange(inPath:testPaths[0], untilSubpath: testSubpaths[0])
        let testPathComponents = PluginsPathHelper.pathComponents(ofPath: testPaths[0], afterSubpath: testSubpaths[0])!
        
        XCTAssertEqual(testPathComponents.count, 1, "The path components count should equal one")
        for testPath: String in testPaths {
            for testSubpath: String in testSubpaths {
                
                let range = PluginsPathHelper.subpathRange(inPath:testPath, untilSubpath: testSubpath)
                XCTAssertTrue(range.location != NSNotFound, "The range should have been found")
                let testPathAsNSString: NSString = testPath as NSString
                let subpathFromRange = testPathAsNSString.substring(with: range)
                XCTAssertEqual(subpathFromRange.standardizingPath,  testSubpath.standardizingPath, "The standardized paths should be equal")
                
                XCTAssertTrue(areEqual(range, testRange), "The ranges should be equal")
                
                let subpath = PluginsPathHelper.subpath(fromPath: testPath, untilSubpath: testSubpath)!
                XCTAssertEqual(subpath.standardizingPath, testSubpath.standardizingPath, "The subpaths should be equal")
                XCTAssertTrue(PluginsPathHelper.contains(testPath, subpath: testSubpath), "The path should contain the subpath")
                
                let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
                XCTAssertEqual(pathComponents, testPathComponents, "The path components should equal the test path components")
                XCTAssertEqual(pathComponents[0], testPluginDirectoryName, "The path component should equal the temporary plugin path component")
            }
        }
    }
    
    func testMissingPath() {
        let testPath = testMissingFilePathComponent
        let testSubpath = (tempPluginsDirectoryPath as NSString).appendingPathComponent(testMissingFilePathComponent)
        
        let range = PluginsPathHelper.subpathRange(inPath:testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
        
        let subpath = PluginsPathHelper.subpath(fromPath: testPath, untilSubpath: testSubpath)
        XCTAssertNil(subpath, "The subpath should be nil")
        
        XCTAssertFalse(PluginsPathHelper.contains(testPath, subpath: testSubpath), "The path should not contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath) as NSArray!
        XCTAssertNil(pathComponents, "The path components should be nil")
    }
    
    // Missing path components should all behave identical to if the path actually exists because handling deleted info dictionaries will be exactly the same this case
    func testMissingPathComponent() {
        
        let testPath = (tempPluginPath as NSString).appendingPathComponent(testMissingFilePathComponent)
        let testSubpath = tempPluginsDirectoryPath!
        
        let range = PluginsPathHelper.subpathRange(inPath:testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location != NSNotFound, "The range should have been found")
        
        let testPathAsNSString: NSString = testPath as NSString
        let subpathFromRange = testPathAsNSString.substring(with: range)
        XCTAssertEqual(subpathFromRange.standardizingPath, testSubpath.standardizingPath, "The standardized paths should be equal")
        
        let subpath = PluginsPathHelper.subpath(fromPath: testPath, untilSubpath: testSubpath)!
        XCTAssertEqual(subpath.standardizingPath, testSubpath.standardizingPath, "The subpaths should be equal")
        XCTAssertTrue(PluginsPathHelper.contains(testPath, subpath: testSubpath), "The path should contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
        let testPathComponents = [testPluginDirectoryName, testMissingFilePathComponent]
        XCTAssertEqual(pathComponents, testPathComponents, "The path component should equal the temporary plugin path component")
    }
    
    func testMissingSubpath() {
        
        let testPath = tempPluginPath!
        let testSubpath = testMissingFilePathComponent
        
        let range = PluginsPathHelper.subpathRange(inPath:testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
        
        let subpath = PluginsPathHelper.subpath(fromPath: testPath, untilSubpath: testSubpath)
        XCTAssertNil(subpath, "The subpath should be nil")
        
        XCTAssertFalse(PluginsPathHelper.contains(testPath, subpath: testSubpath), "The path should not contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath) as NSArray!
        XCTAssertNil(pathComponents, "The path components should be nil")
    }
    
    func testMissingSubpathComponent() {
        
        let testPath = tempPluginPath!
        let testSubpath = (tempPluginsDirectoryPath as NSString).appendingPathComponent(testMissingFilePathComponent)
        
        let range = PluginsPathHelper.subpathRange(inPath:testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
        
        let subpath = PluginsPathHelper.subpath(fromPath: testPath, untilSubpath: testSubpath)
        XCTAssertNil(subpath, "The subpath should be nil")
        
        XCTAssertFalse(PluginsPathHelper.contains(testPath, subpath: testSubpath), "The path should not contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath) as NSArray!
        XCTAssertNil(pathComponents, "The path components should be nil")
    }
    
    func testFullSubpathComponent() {
        
        let testPath = (tempPluginPath as NSString).appendingPathComponent(testPluginInfoDictionaryPathComponent)
        let testSubpath = tempPluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
        let pathComponent = NSString.path(withComponents: pathComponents)
        XCTAssertTrue(PluginsPathHelper.contains(testPluginInfoDictionaryPathComponent, subpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertTrue(PluginsPathHelper.does(pathComponent: testPluginInfoDictionaryPathComponent, matchPathComponent: pathComponent), "The path component should be the path component")
        // Inverse should also be true
        XCTAssertTrue(PluginsPathHelper.contains(pathComponent, subpathComponent: testPluginInfoDictionaryPathComponent), "The path component should contain the subpath component")
        XCTAssertTrue(PluginsPathHelper.does(pathComponent: pathComponent, matchPathComponent: testPluginInfoDictionaryPathComponent), "The path component should be the path component")
    }
    
    func testPartialSubpathComponent() {
        let testPath = (tempPluginPath as NSString).appendingPathComponent("Contents")
        let testSubpath = tempPluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
        let pathComponent = NSString.path(withComponents: pathComponents)
        XCTAssertTrue(PluginsPathHelper.contains(testPluginInfoDictionaryPathComponent, subpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.does(pathComponent: pathComponent, matchPathComponent: testPluginInfoDictionaryPathComponent), "The path component should not be the path component")
    }
    
    func testEmptySubpathComponent() {
        
        let testPath = tempPluginPath!
        let testSubpath = tempPluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
        let pathComponent = NSString.path(withComponents: pathComponents)
        XCTAssertTrue(PluginsPathHelper.contains(testPluginInfoDictionaryPathComponent, subpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.does(pathComponent: pathComponent, matchPathComponent: testPluginInfoDictionaryPathComponent), "The path component not should be the path component")
    }
    
    func testFailingFullSubpathComponent() {
        
        let testPath = (tempPluginPath as NSString).appendingPathComponent("Contents/Resources")
        let testSubpath = tempPluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
        let pathComponent = NSString.path(withComponents: pathComponents)
        XCTAssertFalse(PluginsPathHelper.contains(testPluginInfoDictionaryPathComponent, subpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.does(pathComponent: testPluginInfoDictionaryPathComponent, matchPathComponent: pathComponent), "The path component should not be the path component")
    }
    
    func testFailingPartialSubpathComponent() {
        
        let testPath = (tempPluginPath as NSString).appendingPathComponent("Resources")
        let testSubpath = tempPluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: testSubpath)!
        let pathComponent = NSString.path(withComponents: pathComponents)
        XCTAssertFalse(PluginsPathHelper.contains(testPluginInfoDictionaryPathComponent, subpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.does(pathComponent: testPluginInfoDictionaryPathComponent, matchPathComponent: pathComponent), "The path component should not be the path component")
    }
    
    func testPrivateAliasPluginPathComponent() {
        let testPath = ("/private/" as NSString).appendingPathComponent(pluginPath)
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: testPath, afterSubpath: tempPluginsDirectoryPath)!
        let pathComponent = NSString.path(withComponents: pathComponents)
        let testPluginLastPathComponent = (tempPluginPath as NSString).lastPathComponent
        XCTAssertEqual(pathComponent, testPluginLastPathComponent, "The path components should be equal")
    }
    
}

