//
//  ASIHTTPRequestDelegate.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 13/04/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

@class FotaASIHTTPRequest;

@protocol FotaASIHTTPRequestDelegate <NSObject>

@optional

// These are the default delegate methods for request status
// You can use different ones by setting didStartSelector / didFinishSelector / didFailSelector
- (void)requestStarted:(FotaASIHTTPRequest *)request;
- (void)request:(FotaASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
- (void)request:(FotaASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL;
- (void)requestFinished:(FotaASIHTTPRequest *)request;
- (void)requestFailed:(FotaASIHTTPRequest *)request;
- (void)requestRedirected:(FotaASIHTTPRequest *)request;

// When a delegate implements this method, it is expected to process all incoming data itself
// This means that responseData / responseString / downloadDestinationPath etc are ignored
// You can have the request call a different method by setting didReceiveDataSelector
- (void)request:(FotaASIHTTPRequest *)request didReceiveData:(NSData *)data;

// If a delegate implements one of these, it will be asked to supply credentials when none are available
// The delegate can then either restart the request ([request retryUsingSuppliedCredentials]) once credentials have been set
// or cancel it ([request cancelAuthentication])
- (void)authenticationNeededForRequest:(FotaASIHTTPRequest *)request;
- (void)proxyAuthenticationNeededForRequest:(FotaASIHTTPRequest *)request;

@end
