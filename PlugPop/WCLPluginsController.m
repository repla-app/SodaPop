//
//  WCLPluginsController.m
//  PlugPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import "WCLPluginsController.h"
#import "PlugPop-Swift.h"

@property (nonatomic, strong) MultiCollectionController *multiCollectionController;

@implementation WCLPluginsController

- (instancetype)initWithPlugins:(NSArray *)plugins
{
    self = [super init];
    if (self) {
        _multiCollectionController = [[MultiCollectionController alloc] initWithObjects:plugins key:kPluginNameKey];
    }
    return self;
}

- (void)addPlugin:(Plugin *)plugin
{
    [self.insertObject:plugin inPluginsAt:0];
}

- (void)removePlugin:(Plugin *)plugin
{
    NSUInteger index = [self indexOfObject:plugin];
    if (index != NSNotFound) {
        [self removeObjectFromPluginsAtIndex:index];
    }
}

- (Plugin *)pluginForName:(NSString *)name
{
    id object = [self.multiCollectionController objectForKey:name];
    if ([object isKindOfClass:[Plugin class]]) {
        return object;
    }
}

#pragma mark Required Key-Value Coding To-Many Relationship Compliance

- (NSArray *)plugins
{
    return [self.multiCollectionController objects];
}

- (void)insertObject:(Plugin *)plugin inPluginsAtIndex:(NSUInteger)index
{
    [self.multiCollectionController insertObject:plugin inObjectsAtIndex:index];
}

- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes
{
    [self.multiCollectionController insertObjects:pluginsArray atIndexes:indexes];
}

- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index
{
    [self.multiCollectionController removeObjectFromObjectsAtIndex:index];
}

- (void)removePluginsAtIndexes:(NSIndexSet *)indexes
{
    [self.multiCollectionController removeObjectsAtIndexes:indexes];
}

@end
