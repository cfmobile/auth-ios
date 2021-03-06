//
//  PCFConfig.h
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PCFAuthConfig : NSObject

+ (PCFAuthConfig *)sharedInstance;

+ (NSString *)tokenUrl;
+ (NSString *)authorizeUrl;
+ (NSString *)redirectUrl;
+ (NSString *)clientId;
+ (NSString *)clientSecret;
+ (NSString *)scopes;

@end