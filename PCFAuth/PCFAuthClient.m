//
//  PCFAuthClient.m
//  PCFAuth
//
//  Created by DX122-XL on 2015-02-05.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFAuthClient.h"
#import "PCFAFURLRequestSerialization.h"
#import "PCFAFOAuth2Manager.h"
#import "PCFAuthConfig.h"
#import "PCFAuthCodeHandler.h"
#import "PCFAuth.h"

@implementation PCFAuthClient

static NSString *PCFScopeTokenEndpoint = @"openid+offline_access";
static NSString *PCFScopeAuthorizeEndpoint = @"openid offline_access";


+ (NSURL *)tokenUrl {
    return [NSURL URLWithString:[PCFAuthConfig tokenUrl]];
}

+ (NSURL *)baseUrl {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", self.tokenUrl.scheme, self.tokenUrl.host]];
}

+ (PCFAFOAuth2Manager *)manager {
    PCFAFOAuth2Manager *manager = [PCFAFOAuth2Manager clientWithBaseURL:[PCFAuthClient baseUrl] clientID:[PCFAuthConfig clientId] secret:[PCFAuthConfig clientSecret]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[PCFAuthConfig clientId] password:[PCFAuthConfig clientSecret]];
    return manager;
}

+ (void)grantWithRefreshToken:(NSString *)refreshToken completionBlock:(PCFAuthClientBlock)block {
    [self.manager authenticateUsingOAuthWithURLString:self.tokenUrl.path refreshToken:refreshToken success:^(PCFAFOAuthCredential *credential) {
        if (block) {
            block(credential, nil);
        }
    } failure:^(NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)grantWithUsername:(NSString *)username password:(NSString *)password completionBlock:(PCFAuthClientBlock)block {
    [self.manager authenticateUsingOAuthWithURLString:self.tokenUrl.path username:username password:password scope:PCFScopeTokenEndpoint success:^(PCFAFOAuthCredential *credential) {
        if (block) {
            block(credential, nil);
        }
    } failure:^(NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)grantWithAuthCode:(NSString *)code completionBlock:(PCFAuthClientBlock)block {
    [self.manager authenticateUsingOAuthWithURLString:self.tokenUrl.path code:code redirectURI:[PCFAuthConfig redirectUrl] success:^(PCFAFOAuthCredential *credential) {
        if (block) {
            block(credential, nil);
        }
    } failure:^(NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)grantWithAuthCodeFlow:(UIWebView *)webview completionBlock:(PCFAuthClientBlock)block {
    __block PCFAuthCodeHandler *handler = [[PCFAuthCodeHandler alloc] initWithWebView:webview];
    
    [handler load:self.authCodeRequest completionHandler:^(NSString *code) {
        [self grantWithAuthCode:code completionBlock:block];

        handler = nil; // this forces the block to own a reference to this handler.
    }];
}

+ (NSURLRequest *)authCodeRequest {
    NSString *encodedParams = PCFAFQueryStringFromParametersWithEncoding(self.authCodeParams, NSUTF8StringEncoding);
    NSURL *urlWithParams = [NSURL URLWithString:[[PCFAuthConfig authorizeUrl] stringByAppendingFormat:@"?%@", encodedParams]];
    return [NSURLRequest requestWithURL:urlWithParams];
}

+ (NSDictionary *)authCodeParams {
    return @{
        @"state" : [NSUUID UUID].UUIDString,
        @"redirect_uri" : [PCFAuthConfig redirectUrl],
        @"client_id" : [PCFAuthConfig clientId],
        @"approval_prompt" : @"force",
        @"response_type" : @"code",
        @"scope" : PCFScopeAuthorizeEndpoint,
    };
}

@end
