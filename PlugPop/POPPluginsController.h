//
//  POPPluginsController.h
//  PlugPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "POPPluginsSource.h"

@class Plugin;
@class MultiCollectionController;

NS_ASSUME_NONNULL_BEGIN
@interface POPPluginsController : NSObject <POPPluginsSource>
- (instancetype)initWithPlugins:(NSArray *)plugins;
- (void)addPlugin:(Plugin *)plugin;
- (void)removePlugin:(Plugin *)plugin;
- (nullable Plugin *)pluginWithName:(NSString *)name;
- (nullable Plugin *)pluginWithIdentifier:(NSString *)identifier;
@end
NS_ASSUME_NONNULL_END
