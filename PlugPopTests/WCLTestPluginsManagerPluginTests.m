//
//  PluginTests.m
//  Web Console
//
//  Created by Roben Kleene on 10/20/13.
//  Copyright (c) 2013 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Web_ConsoleTestsConstants.h"
#import "WCLTestPluginManagerTestCase.h"
#import "Web_Console-Swift.h"

@interface WCLTestPluginsManagerPluginTests : WCLTestPluginManagerTestCase
@end

@implementation WCLTestPluginsManagerPluginTests

- (void)testSharedResources
{
    NSString *testSharedResourcePath = [[[PluginsManager sharedInstance] sharedResourcesPath] stringByAppendingPathComponent:kTestSharedResourcePathComponent];
    BOOL isDir;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:testSharedResourcePath isDirectory:&isDir];
    XCTAssertTrue(fileExists, @"A file should exist at the test shared resource's path.");
    XCTAssertFalse(isDir, @"The test shared resource should not be a directory.");
    
    NSURL *testSharedResourceURL = [[[PluginsManager sharedInstance] sharedResourcesURL] URLByAppendingPathComponent:kTestSharedResourcePathComponent];
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[testSharedResourceURL path] isDirectory:&isDir];
    XCTAssertTrue(fileExists, @"A file should exist at the test shared resource's URL.");
    XCTAssertFalse(isDir, @"The test shared resource should not be a directory.");
}

- (void)testPlugin
{
    Plugin *plugin = [[PluginsManager sharedInstance] pluginForName:kTestPrintPluginName];
    
    XCTAssertNotNil(plugin, @"The WCLPlugin should not be nil.");
    
    // Test Resource Path & URL
    BOOL isDir;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[plugin resourcePath] isDirectory:&isDir];
    XCTAssertTrue(fileExists, @"A file should exist at the WCLPlugin's resource path.");
    XCTAssertTrue(isDir, @"The WCLPlugin's resource path should be a directory.");
    XCTAssertTrue([[plugin resourcePath] isEqualToString:[[plugin resourceURL] path]], @"The WCLPlugin's resource path should equal the path to its resource URL.");
    
    // Test Command
    XCTAssertEqualObjects([plugin command], kTestPrintPluginCommand, @"The WCLPlugin's command should match the test plugin command.");
    XCTAssertTrue([[plugin commandPath] hasPrefix:[plugin resourcePath]], @"The WCLPlugin's command path should begin with it's resource path.");
    XCTAssertTrue([[plugin commandPath] hasSuffix:[plugin command]], @"The WCLPlugin's command path should end with it's command.");
    
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[plugin commandPath] isDirectory:&isDir];
    XCTAssertTrue(fileExists, @"A file should exist at the WCLPlugin's command path.");
    XCTAssertFalse(isDir, @"The WCLPlugin's command path should not be a directory.");
}

@end

