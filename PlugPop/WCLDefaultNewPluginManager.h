//
//  WCLDefaultNewPluginManager.h
//  PlugPop
//
//  Created by Roben Kleene on 5/14/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCLPlugin.h"

@class WCLDefaultNewPluginManager;
@class Plugin;

NS_ASSUME_NONNULL_BEGIN
@protocol WCLDefaultNewPluginManagerDataSource
- (nullable Plugin *)defaultNewPluginManager:(WCLDefaultNewPluginManager *)defaultNewPluginManager pluginForIdentifier:(NSString *)identifier;
- (nullable Plugin *)defaultNewPluginManager:(WCLDefaultNewPluginManager *)defaultNewPluginManager pluginForName:(NSString *)name;
@end
NS_ASSUME_NONNULL_END

@protocol DefaultsType;
@protocol DefaultPluginDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface WCLDefaultNewPluginManager : NSObject <DefaultPluginDataSource>
- (instancetype)initWithDefaults:(_Nonnull id <DefaultsType>)defaults;
@property (nonatomic, assign, nullable) id <WCLDefaultNewPluginManagerDataSource> dataSource;
@property (nonatomic, strong, nullable) WCLPlugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END

