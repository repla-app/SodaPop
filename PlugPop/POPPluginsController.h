//
//  POPPluginsController.h
//  PlugPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "POPPluginsSource.h"

NS_ASSUME_NONNULL_BEGIN
@interface POPPluginsController : NSObject <POPPluginsSource>
- (instancetype)initWithPlugins:(NSArray *)plugins;
@end
NS_ASSUME_NONNULL_END
