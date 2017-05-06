//
//  WCLPluginsManager+UniquePluginName.m
//  PlugPop
//
//  Created by Roben Kleene on 5/6/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import "WCLPluginsManager+UniquePluginName.h"

@implementation WCLPluginsManager (UniquePluginName)
+ (NSString *)uniquePluginNameFromName:(NSString *)name
{
    return [self uniquePluginNameFromName:name forPlugin:nil];
}

+ (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(WCLPlugin *)plugin
{
    if ([self isUniqueName:name forPlugin:plugin]) {
        return name;
    }
    
    NSString *newName = [self uniquePluginNameFromName:name forPlugin:plugin index:2];
    
    if (!newName && plugin) {
        newName = plugin.identifier;
    }
    
    return newName;
}


#pragma mark Name Private

+ (BOOL)isUniqueName:(NSString *)name forPlugin:(WCLPlugin *)plugin
{
    Plugin *existingPlugin = [self.pluginsManager pluginForName:name];
    
    if (!existingPlugin) {
        return YES;
    }
    
    // Once we've determined there is an existing plugin, the name is only valid if the existing plugin is this plugin
    if (!plugin) {
        return NO;
    }
    
    return plugin == existingPlugin;
}

+ (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(WCLPlugin *)plugin index:(NSUInteger)index
{
    if (index > 99) {
        return nil;
    }
    
    NSString *newName = [NSString stringWithFormat:@"%@ %lu", name, (unsigned long)index];
    if ([self isUniqueName:newName forPlugin:plugin]) {
        return newName;
    }
    
    index++;
    return [self uniquePluginNameFromName:name
                                forPlugin:plugin
                                    index:index];
}
@end
