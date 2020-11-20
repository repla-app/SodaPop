//
//  POPDefaultNewPluginManager.m
//  SodaPop
//
//  Created by Roben Kleene on 5/14/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

#import "POPDefaultNewPluginManager.h"
#import <SodaPop/SodaPop-Swift.h>

@import PlainBagel;

@interface POPDefaultNewPluginManager ()
@property (nonatomic, strong) id<DefaultsType> defaults;
@property (nonatomic, strong) NSString *fallbackDefaultNewPluginName;
@end

@implementation POPDefaultNewPluginManager

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (instancetype)initWithDefaults:(_Nonnull id<DefaultsType>)defaults
    fallbackDefaultNewPluginName:(NSString *)fallbackDefaultNewPluginName {
    self = [super init];
    if (self) {
        _defaults = defaults;
        _fallbackDefaultNewPluginName = fallbackDefaultNewPluginName;
    }
    return self;
}

- (POPPlugin *)defaultNewPlugin {
    if (_defaultNewPlugin) {
        return _defaultNewPlugin;
    }

    NSString *identifier = [self.defaults stringForKey:kDefaultNewPluginIdentifierKey];
    POPPlugin *plugin;

    if (identifier && self.dataSource) {
        plugin = [self.dataSource defaultNewPluginManager:self pluginWithIdentifier:identifier];
        if (!plugin) {
            [self.defaults removeObjectForKey:kDefaultNewPluginIdentifierKey];
        }
    }

    if (!plugin && self.dataSource) {
        plugin = [self.dataSource defaultNewPluginManager:self pluginWithName:self.fallbackDefaultNewPluginName];
    }

    _defaultNewPlugin = plugin;

    return _defaultNewPlugin;
}

- (void)setDefaultNewPlugin:(Plugin *)defaultNewPlugin {
    if (self.defaultNewPlugin == defaultNewPlugin) {
        return;
    }

    if (!defaultNewPlugin) {
        // Do this early so that the subsequent calls to the getter don't reset
        // the default new plugin
        [self.defaults removeObjectForKey:kDefaultNewPluginIdentifierKey];
    }

    POPPlugin *oldDefaultNewPlugin = _defaultNewPlugin;
    _defaultNewPlugin = defaultNewPlugin;

    if (self.defaultNewPlugin != oldDefaultNewPlugin) {
        oldDefaultNewPlugin.defaultNewPlugin = NO;
    }

    if (_defaultNewPlugin) {
        _defaultNewPlugin.defaultNewPlugin = YES;
        [self.defaults setObject:[(Plugin *)_defaultNewPlugin identifier] forKey:kDefaultNewPluginIdentifierKey];
    }
}

@end
