//
//  SmaBusinessTool.m
//  SmaWatch
//
//  Created by 有限公司 深圳市 on 15/4/1.
//  Copyright (c) 2015年 smawatch. All rights reserved.
//

#import "SmaBusinessTool.h"
#import "SmaBLE.h"
@implementation SmaBusinessTool
static int serialNum=0;

uint16_t const crc16_table[256] =
        {
                0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
                0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
                0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
                0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
                0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
                0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
                0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
                0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
                0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
                0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
                0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
                0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
                0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
                0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
                0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
                0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
                0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
                0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
                0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
                0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
                0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
                0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
                0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
                0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
                0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
                0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
                0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
                0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
                0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
                0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
                0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
                0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040
        };

uint16_t crc16_byte(uint16_t crc, const uint8_t data)
{
    return (crc >> 8) ^ crc16_table[(crc ^ data) & 0xff];
}


uint16_t bd_crc16(uint16_t crc, uint8_t const *buffer, uint16_t len)
{
    while (len--)
        crc = crc16_byte(crc, *buffer++);
    return crc;

}

static const unsigned short crc16tab[256]= {
        0x0000,0x1021,0x2042,0x3063,0x4084,0x50a5,0x60c6,0x70e7,
        0x8108,0x9129,0xa14a,0xb16b,0xc18c,0xd1ad,0xe1ce,0xf1ef,
        0x1231,0x0210,0x3273,0x2252,0x52b5,0x4294,0x72f7,0x62d6,
        0x9339,0x8318,0xb37b,0xa35a,0xd3bd,0xc39c,0xf3ff,0xe3de,
        0x2462,0x3443,0x0420,0x1401,0x64e6,0x74c7,0x44a4,0x5485,
        0xa56a,0xb54b,0x8528,0x9509,0xe5ee,0xf5cf,0xc5ac,0xd58d,
        0x3653,0x2672,0x1611,0x0630,0x76d7,0x66f6,0x5695,0x46b4,
        0xb75b,0xa77a,0x9719,0x8738,0xf7df,0xe7fe,0xd79d,0xc7bc,
        0x48c4,0x58e5,0x6886,0x78a7,0x0840,0x1861,0x2802,0x3823,
        0xc9cc,0xd9ed,0xe98e,0xf9af,0x8948,0x9969,0xa90a,0xb92b,
        0x5af5,0x4ad4,0x7ab7,0x6a96,0x1a71,0x0a50,0x3a33,0x2a12,
        0xdbfd,0xcbdc,0xfbbf,0xeb9e,0x9b79,0x8b58,0xbb3b,0xab1a,
        0x6ca6,0x7c87,0x4ce4,0x5cc5,0x2c22,0x3c03,0x0c60,0x1c41,
        0xedae,0xfd8f,0xcdec,0xddcd,0xad2a,0xbd0b,0x8d68,0x9d49,
        0x7e97,0x6eb6,0x5ed5,0x4ef4,0x3e13,0x2e32,0x1e51,0x0e70,
        0xff9f,0xefbe,0xdfdd,0xcffc,0xbf1b,0xaf3a,0x9f59,0x8f78,
        0x9188,0x81a9,0xb1ca,0xa1eb,0xd10c,0xc12d,0xf14e,0xe16f,
        0x1080,0x00a1,0x30c2,0x20e3,0x5004,0x4025,0x7046,0x6067,
        0x83b9,0x9398,0xa3fb,0xb3da,0xc33d,0xd31c,0xe37f,0xf35e,
        0x02b1,0x1290,0x22f3,0x32d2,0x4235,0x5214,0x6277,0x7256,
        0xb5ea,0xa5cb,0x95a8,0x8589,0xf56e,0xe54f,0xd52c,0xc50d,
        0x34e2,0x24c3,0x14a0,0x0481,0x7466,0x6447,0x5424,0x4405,
        0xa7db,0xb7fa,0x8799,0x97b8,0xe75f,0xf77e,0xc71d,0xd73c,
        0x26d3,0x36f2,0x0691,0x16b0,0x6657,0x7676,0x4615,0x5634,
        0xd94c,0xc96d,0xf90e,0xe92f,0x99c8,0x89e9,0xb98a,0xa9ab,
        0x5844,0x4865,0x7806,0x6827,0x18c0,0x08e1,0x3882,0x28a3,
        0xcb7d,0xdb5c,0xeb3f,0xfb1e,0x8bf9,0x9bd8,0xabbb,0xbb9a,
        0x4a75,0x5a54,0x6a37,0x7a16,0x0af1,0x1ad0,0x2ab3,0x3a92,
        0xfd2e,0xed0f,0xdd6c,0xcd4d,0xbdaa,0xad8b,0x9de8,0x8dc9,
        0x7c26,0x6c07,0x5c64,0x4c45,0x3ca2,0x2c83,0x1ce0,0x0cc1,
        0xef1f,0xff3e,0xcf5d,0xdf7c,0xaf9b,0xbfba,0x8fd9,0x9ff8,
        0x6e17,0x7e36,0x4e55,0x5e74,0x2e93,0x3eb2,0x0ed1,0x1ef0
};

unsigned short crc16_ccitt(Byte *buf, int len)
{
    register int counter;
    register unsigned short crc = 0;
    for( counter = 0; counter < len; counter++)
        crc = (crc<<8) ^ crc16tab[((crc>>8) ^ *(char *)buf++)&0x00FF];
    return crc;
}


+ (Byte *)getEPOFileCmd:(Byte)cmd Key:(Byte)key len:(int)len data:(NSData *)epoData {

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serialNUN" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",serialNum],@"SERIANUM", nil]]];

    Byte results[13];
    results[0]=0xAB;
    results[1]=0x00;
    //版本号、Ack应答状态
    results[2]=(Byte)(((len+5)>>8)&0xff);
    results[3]=(Byte)(((len+5)>>0)&0xff);
    //序列号
    results[6] =(Byte)((serialNum>>8)&0xff);
    results[7] =(Byte)((serialNum>>0)&0xff);
    //命令码
    results[8]=cmd;
    //命名码标示
    results[9] =0x00;
    //key值
    results[10]=key;
    serialNum++;
    //命令内容的长度：value
    results[11] =(Byte)((len>>8)&0xff);
    results[12] =(Byte)((len>>0)&0xff);

    NSData *cmdData = [NSData dataWithBytes:results length:13];

    NSMutableData *sumMData = [[NSMutableData alloc] initWithData:cmdData];
    [sumMData appendData:epoData];

    Byte *sumResults = (Byte *)[sumMData bytes];
    [self getCRC16:sumResults];

    return sumResults;
}

+(void)getSpliceCmd:(Byte)cmd Key:(Byte)key bytes1:(Byte [])bytes1 len:(int)len results:(Byte [])results
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serialNUN" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serialNUN" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",serialNum],@"SERIANUM", nil]]];
    results[0]=0xAB;
    results[1]=0x00;
    //版本号、Ack应答状态
    results[2]=(Byte)(((len+5)>>8)&0xff);
    results[3]=(Byte)(((len+5)>>0)&0xff);
    //序列号
    results[6] =(Byte)((serialNum>>8)&0xff);
    results[7] =(Byte)((serialNum>>0)&0xff);
    //命令码
    results[8]=cmd;
    //命名码标示
    results[9] =0x00;
    //key值
    results[10]=key;
    serialNum++;
    //命令内容的长度：value
    results[11] =(Byte)((len>>8)&0xff);
    results[12] =(Byte)((len>>0)&0xff);

    [self copyValue:bytes1 len:len dataBytes:results len1:13];

    [self getCRC16:results];
}

+ (void)setSerialNum{
    serialNum = 0;
}

+(void)getSpliceCmd1:(Byte)cmd Key:(Byte)key bytes1:(Byte [])bytes1 len:(int)len results:(Byte [])results{
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serialNUN" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serialNUN" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",serialNum],@"SERIANUM", nil]]];
    results[0]=0xAB;
    results[1]=0x00;
    //版本号、Ack应答状态
    results[2]=(Byte)(((len+5)>>8)&0xff);
    results[3]=(Byte)(((len+5)>>0)&0xff);
    //序列号
    results[6] =(Byte)((serialNum>>8)&0xff);
    results[7] =(Byte)((serialNum>>0)&0xff);
    //命令码
    results[8]=cmd;
    //命名码标示
    results[9] =0x00;
    //key值
    results[10]=key;
    serialNum++;

    //命令内容的长度：value
    results[11] =(Byte)((len>>8)&0xff);
    results[12] =(Byte)((len>>0)&0xff);
    results[13] = 0x00;
    results[14] = 0x00;
    results[15] = 0x00;
    results[16] = 0x00;
    results[17] = 0x00;
    results[18] = 0x00;
    results[19] = 0x00;
    results[20] = 0x00;

    [self getCRC16:results];

}

//久坐专用
+(void)getSpliceCmdBand:(Byte)cmd Key:(Byte)key bytes1:(Byte [])bytes1 len:(int)len results:(Byte [])results
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serialNUN" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serialNUN" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",serialNum],@"SERIANUM", nil]]];
    results[0]=0xAB;
    results[1]=0x00;
    //版本号、Ack应答状态
    results[2]=(Byte)(((len+5)>>8)&0xff);
    results[3]=(Byte)(((len+5)>>0)&0xff);
    //序列号
    results[6] =(Byte)((serialNum>>8)&0xff);
    results[7] =(Byte)((serialNum>>0)&0xff);
    //命令码
    results[8]=cmd;
    //命名码标示
    results[9] =0x00;
    //key值
    results[10]=key;
    serialNum++;

    //命令内容的长度：value
    results[11] =(Byte)((len>>8)&0xff);
    results[12] =(Byte)((len>>0)&0xff);

    [self copyValue:bytes1 len:len dataBytes:results len1:13];

    [self getCRC16:results];
}

+(NSData *)getOTAdata{
    Byte buf[13];
    buf[0] = 0xAB;
    buf[1] = 0x00;
    buf[2] = 0x00;
    buf[3] = 0x05;
    buf[4] = 0x00;
    buf[5] = 0x6C;
    buf[6] =(Byte)((serialNum>>8)&0xff);
    buf[7] =(Byte)((serialNum>>0)&0xff);
    buf[8] = 0x01;
    buf[9] = 0x00;
    buf[10] = 0x01;
    buf[11] = 0x00;
    buf[12] = 0x00;
    serialNum++;
    NSData *data = [NSData dataWithBytes:buf length:13];
    return data;
}

+(void)copyValue:(Byte[])bytes len:(Byte)len dataBytes:(Byte[])dataBytes len1:(int)len1
{
    for (int i=0; i<len; i++) {

        dataBytes[len1+i]=bytes[i];
    }
}

/**
 *  <#Description#> CRC16校验方法
 *  @param arrByte 传入需要CRC校验的byte数组
 *  @return 返回CRC校验的结果true false;
 */
+(BOOL)checkCRC16:(Byte [])arrByte{
    uint16_t crc16 = bd_crc16(0,&arrByte[8],(arrByte[2]<<0x008)|arrByte[3]);
    if(arrByte[4]==(crc16>>8&0x0ff) && arrByte[5]==(crc16>>0&0x0ff))
        return  true;
    else
        return  false;
}

/**
 *  <#Description#> CRC16校验方法
 *
 *  @param arrByte 传入需要CRC校验的byte数组
 *
 *  @return 返回CRC校验的结果
 */
+(void)getCRC16:(Byte [])arrByte{
    uint16_t crc16 = bd_crc16(0,&arrByte[8],(arrByte[2]<<0x008)|arrByte[3]);
    arrByte[4]=crc16>>8&0x0ff;
    arrByte[5]=crc16>>0&0x0ff;
}



/**
 *  <#Description#> 是不是应答信号
 *
 *  @param bytes 蓝牙设备返回的结果bytes数组
 *
 *  @return 返回判断结果
 */
+(BOOL)checkNckBytes:(Byte [])bytes
{
    if(bytes[1]==0x10 && bytes[0]==0xAB)
    {

        return false;//应答信号
    }else
    {

        return  true;//非应答信号
    }

}
/**
 *  <#Description#> ACK 应答
 *
 *  @param peripheral 蓝牙设备返回的结果bytes数组
 *
 */
+(void)setAckCmdSeqId:(int16_t)seqId peripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic
{
    Byte nckByte[8];
    nckByte[0]=0xAB;
    nckByte[1]=0x10;
    nckByte[2]=0x00;
    nckByte[3]=0x00;
    nckByte[4]=0x00;
    nckByte[5]=0x00;
    nckByte[6]=(seqId>>8)&0xff;
    nckByte[7]=seqId&0xff;

    NSData *nckData = [NSData dataWithBytes:nckByte length:8];
    [peripheral writeValue:nckData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    //        NSLog(@"ACK 成功  %@",nckData);
}
/**
 *  <#Description#> Nack 应答
 *
 *  @param peripheral 蓝牙设备返回的结果bytes数组
 *
 */
+(void)setNackCmdSeqId:(int16_t)seqId peripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic
{
    Byte nckByte[8];
    nckByte[0]=0xAB;
    nckByte[1]=0x30;
    nckByte[2]=0x00;
    nckByte[3]=0x00;
    nckByte[4]=0x00;
    nckByte[5]=0x00;
    nckByte[6]=(seqId>>8)&0xff;
    nckByte[7]=seqId&0xff;
    NSData *nckData = [NSData dataWithBytes:nckByte length:8];
    [peripheral writeValue:nckData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

+ (void)setBinData:(Byte [])data result:(Byte [])result byteInt:(int)byInt{
    result[0] = 0x01;
    result[1] = (Byte)(0XFF &byInt);
    result[2] =0XFF - (Byte)(0XFF &byInt);
    [self addByte:data allByte:result];
    [self CRC16_ccitt:result];
}

+ (void)addByte:(Byte[])byte allByte:(Byte [])dataBytes{
    for (int i = 0; i < 128; i ++) {
        dataBytes[3+i]=byte[i];
    }
}

+ (void)CRC16_ccitt:(Byte [])arrByte{
    uint16_t crc16 = crc16_ccitt(&arrByte[3], 128);
    arrByte[131] = (crc16>>8)&0xFF;
    arrByte[132] = (crc16>>0)&0xFF;
    //    NSLog(@"---%hu  %d",crc16,(crc16>>8)&0xFF);

}
@end
