//
//  WCLFileExtension+Tests.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/26/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN
@interface WCLFileExtension (Test)
+ (NSDictionary *)fileExtensionToPluginDictionary;
+ (void)setFileExtensionToPluginDictionary:(NSDictionary *)fileExtensionToPluginDictionary;
@end
NS_ASSUME_NONNULL_END
