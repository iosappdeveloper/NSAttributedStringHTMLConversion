//
//  UIFont+HTML.m
//  NSAttributedStringHTMLConversion
//
//  Created by Matoria, Ashok on 8/11/14.
//  Copyright (c) 2014 iOSAppDeveloper. All rights reserved.
//

#import "UIFont+HTML.h"

@implementation UIFont (HTML)


+(NSString *)ab_fontNameFromFamily:(NSString *)familyName withTextStyleTraits:(UIFontDescriptorSymbolicTraits)symoblicTrait
{
    NSString *fontName = nil;
    
    // Font name decision is decided based on bold and italic traits so strip out other traits
    UIFontDescriptorSymbolicTraits boldItalicSymoblicTraits = symoblicTrait & (UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic);
    
    if ([familyName isEqualToString:@"Aller Typo"]) {
        if (boldItalicSymoblicTraits == (UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic)) {
            fontName = @"AllerTypo-Italic";
        }
        else if (boldItalicSymoblicTraits == UIFontDescriptorTraitBold) {
            fontName = @"AllerTypo-Regular";
        }
        else if (boldItalicSymoblicTraits == UIFontDescriptorTraitItalic) {
            fontName = @"AllerTypo-LightItalic";
        }
        else {
            fontName = @"AllerTypo-Light";
        }
    }
    else {
        // For other font families, we simply read and match font type face attributes to pick up the appropriate font.
        // TODO - ashok.matoria - 17-Jul-2014 - Should refine it when there are multiple candidates/font supporting requried type faces within a family.
        // It currently picks up the first font candidate specifying that meets the criteria.
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        
        for (NSInteger index = 0; index < fontNames.count; ++index) {
            UIFont *currentFont = [UIFont fontWithName:fontNames[index] size:12.0];
            // Read bold, italic traits of this font
            UIFontDescriptorSymbolicTraits currentTraits = currentFont.fontDescriptor.symbolicTraits & (UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic);
            
            if (currentTraits == boldItalicSymoblicTraits) {
                fontName = currentFont.fontName;
                break;
            }
        }
    }
    
    NSAssert1(fontName, @"Failed to find font with mentioned traits in provided family %@", familyName);
    
    return fontName;
}

- (UIFontDescriptorSymbolicTraits)ab_textStyleTraits
{
    UIFontDescriptorSymbolicTraits fontTraits = 0;
    
    if ([self.fontName hasPrefix:@"AllerTypo"]) {
        
        if ([self.fontName hasSuffix:@"-Italic"]) {
            fontTraits =  (UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic);
        }
        else if ([self.fontName hasSuffix:@"-Regular"]) {
            fontTraits =  UIFontDescriptorTraitBold;
        }
        else if ([self.fontName hasSuffix:@"-LightItalic"]) {
            fontTraits =  UIFontDescriptorTraitItalic;
        }
    }
    else {
        fontTraits = self.fontDescriptor.symbolicTraits;
    }
    
    return fontTraits;
}

@end
