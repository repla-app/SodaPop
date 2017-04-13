//
//  WCLNameToPluginController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface WCLKeyToObjectController : NSObject
- (instancetype)initWithKey:(NSString *)key;
- (instancetype)initWithKey:(NSString *)key objects:(NSArray *)objects;
- (id)addObject:(id)object;
- (void)removeObject:(id)object;
- (NSArray *)addObjectsFromArray:(NSArray *)plugins;
- (void)removeObjectsFromArray:(NSArray *)plugins;
- (id)objectForKey:(NSString *)key;
- (NSArray *)allObjects;
@end
NS_ASSUME_NONNULL_END

