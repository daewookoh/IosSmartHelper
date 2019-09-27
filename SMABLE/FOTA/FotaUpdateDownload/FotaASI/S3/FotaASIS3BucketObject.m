//
//  ASIS3BucketObject.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 13/07/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "FotaASIS3BucketObject.h"
#import "FotaASIS3ObjectRequest.h"

@implementation FotaASIS3BucketObject

+ (id)objectWithBucket:(NSString *)theBucket
{
	FotaASIS3BucketObject *object = [[[self alloc] init] autorelease];
	[object setBucket:theBucket];
	return object;
}

- (void)dealloc
{
	[bucket release];
	[key release];
	[lastModified release];
	[ETag release];
	[ownerID release];
	[ownerName release];
	[super dealloc];
}

- (FotaASIS3ObjectRequest *)GETRequest
{
	return [FotaASIS3ObjectRequest requestWithBucket:[self bucket] key:[self key]];
}

- (FotaASIS3ObjectRequest *)PUTRequestWithFile:(NSString *)filePath
{
	return [FotaASIS3ObjectRequest PUTRequestForFile:filePath withBucket:[self bucket] key:[self key]];
}

- (FotaASIS3ObjectRequest *)DELETERequest
{
	FotaASIS3ObjectRequest *request = [FotaASIS3ObjectRequest requestWithBucket:[self bucket] key:[self key]];
	[request setRequestMethod:@"DELETE"];
	return request;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Key: %@ lastModified: %@ ETag: %@ size: %llu ownerID: %@ ownerName: %@",[self key],[self lastModified],[self ETag],[self size],[self ownerID],[self ownerName]];
}

- (id)copyWithZone:(NSZone *)zone
{
	FotaASIS3BucketObject *newBucketObject = [[[self class] alloc] init];
	[newBucketObject setBucket:[self bucket]];
	[newBucketObject setKey:[self key]];
	[newBucketObject setLastModified:[self lastModified]];
	[newBucketObject setETag:[self ETag]];
	[newBucketObject setSize:[self size]];
	[newBucketObject setOwnerID:[self ownerID]];
	[newBucketObject setOwnerName:[self ownerName]];
	return newBucketObject;
}

@synthesize bucket;
@synthesize key;
@synthesize lastModified;
@synthesize ETag;
@synthesize size;
@synthesize ownerID;
@synthesize ownerName;
@end
