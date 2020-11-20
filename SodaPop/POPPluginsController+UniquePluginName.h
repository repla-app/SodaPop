//
//  POPPluginsController+UniquePluginName.h
//  SodaPop
//
//  Created by Roben Kleene on 5/6/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import "POPPlugin.h"
#import "POPPluginsController.h"

#define kDuplicatePluginsWithCounterMax 99

@class BasePlugin;

NS_ASSUME_NONNULL_BEGIN
@interface POPPluginsController (UniquePluginName) <UniqueNameDataSource>
- (NSString *)uniquePluginNameFromName:(NSString *)name;
- (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(nullable BasePlugin *)plugin;
- (BOOL)isUniqueName:(NSString *)name forPlugin:(BasePlugin *)plugin;
@end
NS_ASSUME_NONNULL_END
