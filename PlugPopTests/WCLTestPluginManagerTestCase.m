//
//  WCLTestPluginManagerTestCase.m
//  Web Console
//
//  Created by Roben Kleene on 2/8/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"
#import "Web_ConsoleTestsConstants.h"
#import "Web_Console-Swift.h"
#import "XCTestCase+SharedTestResources.h"

@implementation WCLTestPluginManagerTestCase

- (void)setUp
{
    [super setUp];

    // Built-In Plugins
    NSString *builtInPluginsPath = [[NSBundle mainBundle] builtInPlugInsPath];

    // Test Resources Plugins
    NSURL *sharedTestResourcesURL = [[self class] wcl_sharedTestResourcesURL];
    NSURL *testPluginsURL = [sharedTestResourcesURL URLByAppendingPathComponent:kSharedTestResourcesPluginSubdirectory];
    NSString *testPluginsPath = [testPluginsURL path];

    // Trash
    NSError *error;
    NSURL *trashURL = [[NSFileManager defaultManager] URLForDirectory:NSTrashDirectory
                                                             inDomain:NSUserDomainMask
                                                    appropriateForURL:nil
                                                               create:NO
                                                                error:&error];
    XCTAssertNil(error, @"The error should be nil");

    
    PluginsManager *pluginsManager = [[PluginsManager alloc] initWithPaths:@[builtInPluginsPath, testPluginsPath]
                           duplicatePluginDestinationDirectoryURL:trashURL];
    
    [PluginsManager setOverrideSharedInstance:pluginsManager];
}

- (void)tearDown
{
    [super tearDown];
    [PluginsManager setOverrideSharedInstance:nil];
}

@end
