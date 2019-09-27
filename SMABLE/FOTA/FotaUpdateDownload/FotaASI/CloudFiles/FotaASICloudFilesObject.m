//
//  ASICloudFilesObject.m
//
//  Created by Michael Mayo on 1/7/10.
//

#import "FotaASICloudFilesObject.h"


@implementation FotaASICloudFilesObject

@synthesize name, hash, bytes, contentType, lastModified, data, metadata;

+ (id)object {
	FotaASICloudFilesObject *object = [[[self alloc] init] autorelease];
	return object;
}

-(void)dealloc {
	[name release];
	[hash release];
	[contentType release];
	[lastModified release];
	[data release];
	[metadata release];
	[super dealloc];
}

@end
