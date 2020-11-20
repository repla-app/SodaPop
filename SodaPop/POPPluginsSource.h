//
//  POPPluginsSource.h
//  SodaPop
//
//  Created by Roben Kleene on 12/21/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BasePlugin;

NS_ASSUME_NONNULL_BEGIN
@protocol POPPluginsSource <NSObject>
- (void)addPlugin:(BasePlugin *)plugin;
- (void)removePlugin:(BasePlugin *)plugin;
- (nullable BasePlugin *)pluginWithName:(NSString *)name;
- (nullable BasePlugin *)pluginWithIdentifier:(NSString *)identifier;
#pragma mark Required Key-Value Coding To-Many Relationship Compliance
- (NSArray<BasePlugin *> *)plugins;
- (void)insertObject:(BasePlugin *)plugin inPluginsAtIndex:(NSUInteger)index;
- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index;
- (void)removePluginsAtIndexes:(NSIndexSet *)indexes;
@end
NS_ASSUME_NONNULL_END
