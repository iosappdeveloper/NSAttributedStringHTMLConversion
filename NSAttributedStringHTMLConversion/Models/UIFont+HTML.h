//
//  UIFont+HTML.h
//  NSAttributedStringHTMLConversion
//
//  Created by Matoria, Ashok on 8/11/14.
//  Copyright (c) 2014 iOSAppDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (HTML)

+ (NSString *)ab_fontNameFromFamily:(NSString *)familyName withTextStyleTraits:(UIFontDescriptorSymbolicTraits)symoblicTrait;
- (UIFontDescriptorSymbolicTraits)ab_textStyleTraits;

@end
