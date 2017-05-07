//
//  PluginManager.h
//  PluginTest
//
//  Created by Roben Kleene on 7/3/13.
//  Copyright (c) 2013 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plugin;
@class MultiCollectionController;

NS_ASSUME_NONNULL_BEGIN
@interface WCLPluginsManager : NSObject
@property (nonatomic, strong, nullable) Plugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END
