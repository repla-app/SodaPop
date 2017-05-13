//
//  PluginManager.m
//  PluginTest
//
//  Created by Roben Kleene on 7/3/13.
//  Copyright (c) 2013 Roben Kleene. All rights reserved.
//

#import "WCLPluginsManager.h"
#import <PlugPop/PlugPop-Swift.h>

@interface WCLPluginsManager ()
@property (nonatomic, strong) id <DefaultsType> *defaults;
@end

@implementation WCLPluginsManager

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (instancetype)initWithDefaults:(id <DefaultsType> *)defaults
{
    self = [super init];
    if (self) {
        _defaults = defaults;
    }
    return self;
}

- (Plugin *)defaultNewPlugin
{
    if (_defaultNewPlugin) {
        return _defaultNewPlugin;
    }
    
    NSString *identifier = [self.defaults stringForKey:kDefaultNewPluginIdentifierKey];
    
    Plugin *plugin;
    
    if (identifier) {
        plugin = [self pluginWithIdentifier:identifier];
        if (!plugin) {
            [self.defaults removeObjectForKey:kDefaultNewPluginIdentifierKey];
        }
    }

    if (!plugin) {
        plugin = [self pluginForName:kInitialDefaultNewPluginName];
    }
    
    _defaultNewPlugin = plugin;
    
    return _defaultNewPlugin;
}

- (void)setDefaultNewPlugin:(Plugin *)defaultNewPlugin
{
    if (self.defaultNewPlugin == defaultNewPlugin) {
        return;
    }
    
    if (!defaultNewPlugin) {
        // Do this early so that the subsequent calls to the getter don't reset the default new plugin
        [self.defaults removeObjectForKey:kDefaultNewPluginIdentifierKey];
    }
    
    Plugin *oldDefaultNewPlugin = _defaultNewPlugin;
    _defaultNewPlugin = defaultNewPlugin;
    
    oldDefaultNewPlugin.defaultNewPlugin = NO;
    
    _defaultNewPlugin.defaultNewPlugin = YES;
    
    if (_defaultNewPlugin) {
        [self.defaults setObject:_defaultNewPlugin.identifier
                                                  forKey:kDefaultNewPluginIdentifierKey];
    }
}

- (Plugin *)pluginWithIdentifier:(NSString *)identifier
{
    NSAssert(NO, @"Implemented in superclass");
    return nil;
}

- (Plugin *)pluginForName:(NSString *)name
{
    NSAssert(NO, @"Implemented in superclass");
    return nil;
}

@end
