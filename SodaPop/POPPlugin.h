//
//  Plugin.h
//  PluginTest
//
//  Created by Roben Kleene on 7/3/13.
//  Copyright (c) 2013 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POPPlugin;

NS_ASSUME_NONNULL_BEGIN
@protocol DefaultPluginDataSource
@property (nonatomic, nullable) POPPlugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@protocol UniqueNameDataSource
- (BOOL)isUniqueName:(NSString *)name forPlugin:(POPPlugin *)plugin;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface POPPlugin : NSObject
@property (nonatomic, weak, nullable) id<DefaultPluginDataSource> defaultPluginDataSource;
@property (nonatomic, weak, nullable) id<UniqueNameDataSource> uniqueNameDataSource;
@property (nonatomic, assign, getter=isDefaultNewPlugin) BOOL defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END
