//
//  NSString+WhiteSpace.m
//  获取相册权限
//
//  Created by 陈博文 on 16/9/14.
//  Copyright © 2016年 陈博文. All rights reserved.
//

#import "NSString+WhiteSpace.h"

@implementation NSString (WhiteSpace)


- (NSString *)filterWhiteSpace{
    
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)filterMinus{
    
    return [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
}




@end
