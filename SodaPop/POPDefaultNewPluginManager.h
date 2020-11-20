//
//  POPDefaultNewPluginManager.h
//  SodaPop
//
//  Created by Roben Kleene on 5/14/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

#import "POPPlugin.h"
#import <Foundation/Foundation.h>

#define kDefaultNewPluginIdentifierKey @"POPDefaultNewPluginIdentifier"

@class POPDefaultNewPluginManager;
@class BasePlugin;

NS_ASSUME_NONNULL_BEGIN
@protocol POPDefaultNewPluginManagerDataSource
- (nullable BasePlugin *)defaultNewPluginManager:(POPDefaultNewPluginManager *)defaultNewPluginManager
                        pluginWithIdentifier:(NSString *)identifier;
- (nullable BasePlugin *)defaultNewPluginManager:(POPDefaultNewPluginManager *)defaultNewPluginManager
                              pluginWithName:(NSString *)name;
@end
NS_ASSUME_NONNULL_END

@protocol DefaultsType;
@protocol DefaultPluginDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface POPDefaultNewPluginManager : NSObject <DefaultPluginDataSource>
- (instancetype)initWithDefaults:(_Nonnull id<DefaultsType>)defaults
    fallbackDefaultNewPluginName:(NSString *)defaultNewPluginName;
@property (nonatomic, strong, nullable) id<POPDefaultNewPluginManagerDataSource> dataSource;
@property (nonatomic, strong, nullable) POPPlugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END
