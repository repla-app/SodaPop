//
//  WCLPluginsManager+UniquePluginName.h
//  PlugPop
//
//  Created by Roben Kleene on 5/6/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import "WCLPluginsController.h"

@class WCLPlugin;

NS_ASSUME_NONNULL_BEGIN
@interface WCLPluginsController (UniquePluginName)
- (NSString *)uniquePluginNameFromName:(NSString *)name;
- (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(nullable WCLPlugin *)plugin;
@end
NS_ASSUME_NONNULL_END
