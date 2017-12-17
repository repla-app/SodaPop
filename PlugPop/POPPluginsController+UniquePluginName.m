//
//  POPPluginsManager+UniquePluginName.m
//  PlugPop
//
//  Created by Roben Kleene on 5/6/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import "POPPluginsController+UniquePluginName.h"
#import <PlugPop/PlugPop-Swift.h>

@implementation POPPluginsController (UniquePluginName)

- (NSString *)uniquePluginNameFromName:(NSString *)name
{
    return [self uniquePluginNameFromName:name
                                forPlugin:nil];
}

- (NSString *)uniquePluginNameFromName:(NSString *)name
                             forPlugin:(Plugin *)plugin
{
    if ([self isUniqueName:name forPlugin:plugin]) {
        return name;
    }
    
    NSString *newName = [self uniquePluginNameFromName:name forPlugin:plugin
                                                 index:2];
    
    if (!newName && plugin) {
        newName = plugin.identifier;
    }
    
    return newName;
}

#pragma mark Name Private

- (BOOL)isUniqueName:(NSString *)name forPlugin:(Plugin *)plugin
{
    Plugin *existingPlugin = [self pluginWithName:name];
    
    if (!existingPlugin) {
        return YES;
    }
    
    // if there is an `existingPlugin`, then the name is only valid if the
    // `existingPlugin` is the `plugin`. So first confirm that the `plugin`
    // is not nil.
    if (!plugin) {
        return NO;
    }

    return plugin == existingPlugin;
}

- (NSString *)uniquePluginNameFromName:(NSString *)name
                             forPlugin:(Plugin *)plugin
                                 index:(NSUInteger)index
{
    if (index > kDuplicatePluginsWithCounterMax) {
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
