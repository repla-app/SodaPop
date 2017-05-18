//
//  WCLDefaultNewPluginManager.h
//  PlugPop
//
//  Created by Roben Kleene on 5/14/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WCLDefaultNewPluginManagerDataSource <NSObject>
- (Plugin *)defaultNewPluginManager:(WCLDefaultNewPluginManager *)defaultNewPluginManager pluginForIdentifier:(NSString *)identifier;
- (Plugin *)defaultNewPluginManager:(WCLDefaultNewPluginManager *)defaultNewPluginManager pluginForName:(NSString *)name;
@end
NS_ASSUME_NONNULL_END

@class Plugin;
@protocol DefaultsType;
@protocol DefaultPluginDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface WCLDefaultNewPluginManager : NSObject <DefaultPluginDataSource>
- (instancetype)initWithDefaults:(_Nonnull id <DefaultsType> * _Nonnull)defaults;
@property (nonatomic, assign, nullable) id <WCLDefaultNewPluginManagerDataSource> *dataSource;
@property (nonatomic, strong, nullable) Plugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END

