//
//  ASICloudFilesContainerXMLParserDelegate.h
//
//  Created by Michael Mayo on 1/10/10.
//

#import "FotaASICloudFilesRequest.h"

#if !TARGET_OS_IPHONE || (TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_4_0)
#import "ASINSXMLParserCompat.h"
#endif

@class FotaASICloudFilesContainer;

@interface FotaASICloudFilesContainerXMLParserDelegate : NSObject <NSXMLParserDelegate> {
		
	NSMutableArray *containerObjects;

	// Internally used while parsing the response
	NSString *currentContent;
	NSString *currentElement;
	FotaASICloudFilesContainer *currentObject;
}

@property (retain) NSMutableArray *containerObjects;

@property (retain) NSString *currentElement;
@property (retain) NSString *currentContent;
@property (retain) FotaASICloudFilesContainer *currentObject;

@end
