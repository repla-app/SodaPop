//
//  WCLDefaultNewPluginManager.h
//  PlugPop
//
//  Created by Roben Kleene on 5/14/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plugin;
@protocol DefaultsType;

NS_ASSUME_NONNULL_BEGIN
@interface WCLDefaultNewPluginManager : NSObject
- (instancetype)initWithDefaults:(_Nonnull id <DefaultsType> * _Nonnull)defaults;
@property (nonatomic, strong, nullable) Plugin *defaultNewPlugin;
@end
NS_ASSUME_NONNULL_END

