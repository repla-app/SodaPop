//
//  Plugin.m
//  PluginTest
//
//  Created by Roben Kleene on 7/3/13.
//  Copyright (c) 2013 Roben Kleene. All rights reserved.
//

#import "POPPlugin.h"
#import <PlugPop/PlugPop-Swift.h>

@implementation POPPlugin

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (void)setDefaultNewPlugin:(BOOL)defaultNewPlugin
{
    if ([self isDefaultNewPlugin] == defaultNewPlugin) {
        return;
    }

    if (defaultNewPlugin) {
        self.dataSource.defaultNewPlugin = self;
    } else if (self.dataSource.defaultNewPlugin == self) {
        self.dataSource.defaultNewPlugin = nil;
    }

    _defaultNewPlugin = (self.dataSource.defaultNewPlugin == self);
}

- (BOOL)isDefaultNewPlugin
{
    if (!self.dataSource) {
        return NO;
    }

    BOOL isDefaultNewPlugin = (self.dataSource.defaultNewPlugin == self);
    
    if (_defaultNewPlugin != isDefaultNewPlugin) {
        _defaultNewPlugin = isDefaultNewPlugin;
    }
    
    return _defaultNewPlugin;
}

@end
