//
//  AFNetRequestManager.h
//  10T
//
//  Created by zshuo50 on 2018/5/15.
//  Copyright © 2018年 SMA. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FotaResponseSuccess)(id FotaresponseObject);
typedef void (^FotaResponseFail)(NSError *Fotaerror);

typedef NS_ENUM(NSUInteger, FotaRequestType) {  //请求类型
    FotaRequestTypeJSON = 1,    //JSON
    FotaRequestTypePlainText   //默认，普通text/plain
};

typedef NS_ENUM(NSUInteger, FotaResponseType) {  //输出类型
    FotaResponseTypeJSON = 1,  //默认JSON
    FotaResponseTypeXML,       //XML
    FotaResponseTypeData       //Data  二进制数据
};


@interface FotaAFNetRequestManager : NSObject

+ (void)FotaconfigRequestType:(FotaRequestType)FotarequestType;
+ (void)FotaconfigResponseType:(FotaResponseType)FotaresponseType;

#pragma mark - 请求接口数据  Get/Post
+ (NSURLSessionDataTask *)FotagetWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters success:(FotaResponseSuccess)success fail:(FotaResponseFail)fail;

+ (NSURLSessionDataTask *)FotapostWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters success:(FotaResponseSuccess)success fail:(FotaResponseFail)fail;

+ (NSURLSessionDownloadTask *)FotaDownloadFileWithURL:(NSString *)UrlString Success:(FotaResponseSuccess)success fail:(FotaResponseFail)fail;

//Get the current timestamp (seconds)
+(NSString *)getNowTimeTimestamp2;

//hmacmd5
+ (NSString *)hmac_MD5:(NSString *)plaintext withKey:(NSString *)key;
@end
