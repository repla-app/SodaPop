//
//  WCLPluginsController.h
//  PlugPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface WCLPluginsController : NSObject
- (instancetype)initWithPlugins:(NSArray *)plugins;
- (void)addPlugin:(Plugin *)plugin;
- (void)removePlugin:(Plugin *)plugin;
- (Plugin *)pluginForName:(nullable NSString *)name;
#pragma mark Required Key-Value Coding To-Many Relationship Compliance
- (void)addPlugin:(Plugin *)plugin;
- (NSArray *)plugins;
- (void)insertObject:(Plugin *)plugin inPluginsAtIndex:(NSUInteger)index;
- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index;
- (void)removePluginsAtIndexes:(NSIndexSet *)indexes;
@end
NS_ASSUME_NONNULL_END
