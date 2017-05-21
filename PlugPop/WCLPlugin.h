//
//  Plugin.h
//  PluginTest
//
//  Created by Roben Kleene on 7/3/13.
//  Copyright (c) 2013 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

NS_ASSUME_NONNULL_BEGIN
@protocol DefaultPluginDataSource
@property (nonatomic, nullable) WCLPlugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface WCLPlugin : NSObject
@property (nonatomic, weak, nullable) id <DefaultPluginDataSource> dataSource;
@property (nonatomic, assign, getter = isDefaultNewPlugin) BOOL defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END
