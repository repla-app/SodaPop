//
//  WCLPluginsManager+UniquePluginName.h
//  PlugPop
//
//  Created by Roben Kleene on 5/6/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <PlugPop/PlugPop.h>

@interface WCLPluginsManager (UniquePluginName)
+ (NSString *)uniquePluginNameFromName:(NSString *)name;
+ (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(nullable WCLPlugin *)plugin;
@end
