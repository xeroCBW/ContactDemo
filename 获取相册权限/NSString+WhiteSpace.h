//
//  NSString+WhiteSpace.h
//  获取相册权限
//
//  Created by 陈博文 on 16/9/14.
//  Copyright © 2016年 陈博文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WhiteSpace)
/**
 *  过滤空格
 *
 *  @return 返回过滤空格的字符串
 */
- (NSString *)filterWhiteSpace;

/**
 *  过滤"-"
 *
 *  @return 返回过滤"-"的字符串
 */
- (NSString *)filterMinus;
@end
