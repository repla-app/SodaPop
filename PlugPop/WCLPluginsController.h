//
//  WCLPluginsController.h
//  PlugPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plugin;

NS_ASSUME_NONNULL_BEGIN
@interface WCLPluginsController : NSObject
- (instancetype)initWithPlugins:(NSArray *)plugins;
- (void)addPlugin:(Plugin *)plugin;
- (void)removePlugin:(Plugin *)plugin;
- (nullable Plugin *)pluginForName:(NSString *)name;
- (nullable Plugin *)pluginForIdentifier:(NSString *)identifier;
#pragma mark Required Key-Value Coding To-Many Relationship Compliance
- (NSArray *)plugins;
- (void)insertObject:(Plugin *)plugin inPluginsAtIndex:(NSUInteger)index;
- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index;
- (void)removePluginsAtIndexes:(NSIndexSet *)indexes;
@end
NS_ASSUME_NONNULL_END
