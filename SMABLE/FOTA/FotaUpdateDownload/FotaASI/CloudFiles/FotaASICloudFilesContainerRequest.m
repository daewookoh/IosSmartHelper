//
//  ASICloudFilesContainerRequest.m
//
//  Created by Michael Mayo on 1/6/10.
//

#import "FotaASICloudFilesContainerRequest.h"
#import "FotaASICloudFilesContainer.h"
#import "FotaASICloudFilesContainerXMLParserDelegate.h"


@implementation FotaASICloudFilesContainerRequest

@synthesize currentElement, currentContent, currentObject;
@synthesize xmlParserDelegate;

#pragma mark -
#pragma mark Constructors

+ (id)storageRequestWithMethod:(NSString *)method containerName:(NSString *)containerName queryString:(NSString *)queryString {
	NSString *urlString;
	if (containerName == nil) {
		urlString = [NSString stringWithFormat:@"%@%@", [FotaASICloudFilesRequest storageURL], queryString];
	} else {
		urlString = [NSString stringWithFormat:@"%@/%@%@", [FotaASICloudFilesRequest storageURL], containerName, queryString];
	}

	FotaASICloudFilesContainerRequest *request = [[[FotaASICloudFilesContainerRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[FotaASICloudFilesRequest authToken]];
	return request;
}

+ (id)storageRequestWithMethod:(NSString *)method queryString:(NSString *)queryString {
	return [FotaASICloudFilesContainerRequest storageRequestWithMethod:method containerName:nil queryString:queryString];
}

+ (id)storageRequestWithMethod:(NSString *)method {
	return [FotaASICloudFilesContainerRequest storageRequestWithMethod:method queryString:@""];
}

#pragma mark -
#pragma mark HEAD - Retrieve Container Count and Total Bytes Used

// HEAD /<api version>/<account>
// HEAD operations against an account are performed to retrieve the number of Containers and the total bytes stored in Cloud Files for the account. This information is returned in two custom headers, X-Account-Container-Count and X-Account-Bytes-Used.
+ (id)accountInfoRequest {
	FotaASICloudFilesContainerRequest *request = [FotaASICloudFilesContainerRequest storageRequestWithMethod:@"HEAD"];
	return request;
}

- (NSUInteger)containerCount {
	return [[[self responseHeaders] objectForKey:@"X-Account-Container-Count"] intValue];
}

- (NSUInteger)bytesUsed {
	return [[[self responseHeaders] objectForKey:@"X-Account-Bytes-Used"] intValue];
}

#pragma mark -
#pragma mark GET - Retrieve Container List

+ (id)listRequestWithLimit:(NSUInteger)limit marker:(NSString *)marker {
	NSString *queryString = @"?format=xml";
	
	if (limit > 0) {
		queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&limit=%i", limit]];
	}
	
	if (marker != nil) {
		queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&marker=%@", marker]];
	}
	
	FotaASICloudFilesContainerRequest *request = [FotaASICloudFilesContainerRequest storageRequestWithMethod:@"GET" queryString:queryString];
	return request;
}

// GET /<api version>/<account>/<container>
// Create a request to list all containers
+ (id)listRequest {
	FotaASICloudFilesContainerRequest *request = [FotaASICloudFilesContainerRequest storageRequestWithMethod:@"GET" 
																			queryString:@"?format=xml"];
	return request;
}

- (NSArray *)containers {
	if (xmlParserDelegate.containerObjects) {
		return xmlParserDelegate.containerObjects;
	}
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self responseData]] autorelease];
	if (xmlParserDelegate == nil) {
		xmlParserDelegate = [[FotaASICloudFilesContainerXMLParserDelegate alloc] init];
	}
	
	[parser setDelegate:xmlParserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	return xmlParserDelegate.containerObjects;
}

#pragma mark -
#pragma mark PUT - Create Container

// PUT /<api version>/<account>/<container>
+ (id)createContainerRequest:(NSString *)containerName {
	FotaASICloudFilesContainerRequest *request = [FotaASICloudFilesContainerRequest storageRequestWithMethod:@"PUT" containerName:containerName queryString:@""];
	return request;
}

#pragma mark -
#pragma mark DELETE - Delete Container

// DELETE /<api version>/<account>/<container>
+ (id)deleteContainerRequest:(NSString *)containerName {
	FotaASICloudFilesContainerRequest *request = [FotaASICloudFilesContainerRequest storageRequestWithMethod:@"DELETE" containerName:containerName queryString:@""];
	return request;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[currentElement release];
	[currentContent release];
	[currentObject release];
	[xmlParserDelegate release];
	[super dealloc];
}

@end
