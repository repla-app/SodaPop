//
//  POPPluginsController.h
//  SodaPop
//
//  Created by Roben Kleene on 5/7/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SodaPop/POPPluginsSource.h>

// The `POPPluginsController` manages the in memory `Plugin` objects. It
// provides standard methods for operating on a collection of `Plugin` objects
// compatible with Cocoa bindings.

NS_ASSUME_NONNULL_BEGIN
@interface POPPluginsController : NSObject <POPPluginsSource>
- (instancetype)initWithPlugins:(NSArray *)plugins;
@end
NS_ASSUME_NONNULL_END
