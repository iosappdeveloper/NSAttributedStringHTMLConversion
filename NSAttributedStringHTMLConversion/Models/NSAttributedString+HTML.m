//
//  NSAttributedString+HTML.m
//  NSAttributedStringHTMLConversion
//
//  Created by Matoria, Ashok on 8/11/14.
//  Copyright (c) 2014 iOSAppDeveloper. All rights reserved.
//

#import "NSAttributedString+HTML.h"

#import "QGRichTextTag.h"
#import "UIFont+HTML.h"

#define kTrackAttribKeys (@[NSFontAttributeName, NSUnderlineStyleAttributeName, NSForegroundColorAttributeName])

@implementation NSAttributedString (HTMLEntityConversion)

- (NSString *)ab_encodedHTMLString
{
    //    NSMutableString *encodedHTMLStr = [[NSMutableString alloc] init];
    NSRange enumerationRange = NSMakeRange(0, self.string.length);
    __block NSDictionary *prevTextRunAttribs = [self ab_attributesAfterAddingDefaultAttribs:[[NSDictionary alloc] init]];
    __block NSMutableArray *encodedHTMLStrComponents = [[NSMutableArray alloc] init];
    
    // Iterate over various text runs and generate html
    [self enumerateAttributesInRange:enumerationRange
                             options:0
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                              // Get current range attributes
                              NSDictionary *currentRunAttribs = [self ab_attributesAfterAddingDefaultAttribs:attrs];
                              // Find out the conflicting attributes in this text run.
                              NSDictionary *conflictingAttribs = [self ab_conflictingAttributesFromAttribs:prevTextRunAttribs andAttribs:currentRunAttribs];
                              // Generate the encoded html code for these attributes
                              NSArray *htmlTags = [self ab_encodedHTMLTagsForAttribs:conflictingAttribs compareAttribs:prevTextRunAttribs];
                              
                              [encodedHTMLStrComponents addObjectsFromArray:htmlTags];
                              [encodedHTMLStrComponents addObject:[self.string substringWithRange:range]];
                              
                              prevTextRunAttribs = currentRunAttribs;
                          }];
    
    NSDictionary *currentRunAttribs = [self ab_attributesAfterAddingDefaultAttribs:[[NSDictionary alloc] init]];
    // Find out the conflicting attributes in this text run.
    NSDictionary *conflictingAttribs = [self ab_conflictingAttributesFromAttribs:prevTextRunAttribs andAttribs:currentRunAttribs];
    // Generate the encoded html code for these attributes
    NSArray *htmlTags = [self ab_encodedHTMLTagsForAttribs:conflictingAttribs compareAttribs:prevTextRunAttribs];
    
    [encodedHTMLStrComponents addObjectsFromArray:htmlTags];
    
    return [self encodedHTMLStringFromComponents:encodedHTMLStrComponents];
}

- (NSString *)encodedHTMLStringFromComponents:(NSArray *)htmlComponents
{
    NSMutableString *encodedHTMLString = [[NSMutableString alloc] init];
    
    for (NSObject *aComponent in htmlComponents) {
        if ([aComponent isKindOfClass:[NSString class]]) {
            [encodedHTMLString appendString:(NSString *)aComponent];
        }
        else {
            NSAssert([aComponent isKindOfClass:[QGTag class]], @"Unexpected object type");
            QGTag *tag = (QGTag *)aComponent;
            [encodedHTMLString appendString:tag.tagValue];
        }
    }
    
    return encodedHTMLString;
}

- (NSDictionary *)ab_attributesAfterAddingDefaultAttribs:(NSDictionary *)attribs
{
    NSMutableDictionary *updatedAttribs = [attribs mutableCopy];
    
    for (NSString *defaultAttribKey in kTrackAttribKeys) {
        if (attribs[defaultAttribKey] == nil) {
            id defaultValue = [self ab_defaultValueForAttribKey:defaultAttribKey];
            
            [updatedAttribs setObject:defaultValue forKey:defaultAttribKey];
        }
    }
    
    return updatedAttribs;
}

// Default text attribute values for a key and any deviation will result into encoded HTML String.
- (id)ab_defaultValueForAttribKey:(NSString *)key
{
    id defaultValue = nil;
    
    if ([key isEqualToString:NSFontAttributeName]) {
        defaultValue = [UIFont systemFontOfSize:12];
    }
    else if ([key isEqualToString:NSForegroundColorAttributeName]) {
        defaultValue = [UIColor blackColor];
    }
    else if ([key isEqualToString:NSUnderlineStyleAttributeName]) {
        defaultValue = @(0);    // No underline
    }
    
    return defaultValue;
}

// Compare the attributes array and returns only the conflicting (different) attributes.
// It compares only specific attributes listed in kTrackAttribKeys macro.
- (NSDictionary *)ab_conflictingAttributesFromAttribs:(NSDictionary *)firstAttrib andAttribs:(NSDictionary *)secondAttribs
{
    NSMutableDictionary *conflictingAttribs = [NSMutableDictionary dictionaryWithCapacity:firstAttrib.allKeys.count];
    
    for (NSString *attribKey in kTrackAttribKeys) {
        if (firstAttrib[attribKey] && ![firstAttrib[attribKey] isEqual:secondAttribs[attribKey]]) {
            [conflictingAttribs setObject:secondAttribs[attribKey] forKey:attribKey];
        }
    }
    
    return conflictingAttribs;
}

- (NSArray *)ab_encodedHTMLTagsForAttribs:(NSDictionary *)attribs compareAttribs:(NSDictionary *)previousAttribs
{
    NSMutableArray *encodedHTMLTags = [[NSMutableArray alloc] init];
    
    // Iterate through all the keys of interest (Order matters since span/color should be last to open if there are any closing tags)
    for (NSString *key in attribs) {
        id value = attribs[key];
        QGTag *htmlTag = nil;
        
        if ([key isEqualToString:NSFontAttributeName]) {
            UIFont *newFont = (UIFont *)value;
            UIFont *previousFont = previousAttribs[NSFontAttributeName];
            UIFontDescriptorSymbolicTraits newFontDescriptorSymbolicTraits = [newFont ab_textStyleTraits];
            UIFontDescriptorSymbolicTraits previousFontDescriptorSymbolicTraits = [previousFont ab_textStyleTraits];
            BOOL hasBold = newFontDescriptorSymbolicTraits & UIFontDescriptorTraitBold;
            BOOL hasItalic = newFontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic;
            BOOL hadBold = previousFontDescriptorSymbolicTraits & UIFontDescriptorTraitBold;
            BOOL hadItalic = previousFontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic;
            
            if (hasBold && !hadBold) {
                htmlTag = [QGBoldTag tagWithType:QGTagFaceTypeOpen];
                [encodedHTMLTags addObject:htmlTag];
            }
            else if (!hasBold && hadBold) {
                htmlTag = [QGBoldTag tagWithType:QGTagFaceTypeClose];
                [encodedHTMLTags addObject:htmlTag];
            }
            
            if (hasItalic && !hadItalic) {
                htmlTag = [QGItalicTag tagWithType:QGTagFaceTypeOpen];
                [encodedHTMLTags addObject:htmlTag];
            }
            else if (!hasItalic && hadItalic) {
                htmlTag = [QGItalicTag tagWithType:QGTagFaceTypeClose];
                [encodedHTMLTags addObject:htmlTag];
            }
        }
        else if ([key isEqualToString:NSUnderlineStyleAttributeName]) {
            BOOL hasUnderline = [attribs[NSUnderlineStyleAttributeName] integerValue] == 1;
            BOOL hadUnderline = [previousAttribs[NSUnderlineStyleAttributeName] integerValue] == 1;
            
            if (hasUnderline && !hadUnderline) {
                htmlTag = [QGUnderlineTag tagWithType:QGTagFaceTypeOpen];
                [encodedHTMLTags addObject:htmlTag];
            }
            else if (!hasUnderline && hadUnderline) {
                htmlTag = [QGUnderlineTag tagWithType:QGTagFaceTypeClose];
                [encodedHTMLTags addObject:htmlTag];
            }
        }
        else if ([key isEqualToString:NSForegroundColorAttributeName]) {
            NSString *kTextColorAttribKey = NSForegroundColorAttributeName;
            UIColor *textColor = (UIColor *)value;
            UIColor *prevColor = previousAttribs[kTextColorAttribKey];
            
            if (![prevColor isEqual:[self ab_defaultValueForAttribKey:kTextColorAttribKey]]) {
                htmlTag = [QGSpanTag tagWithType:QGTagFaceTypeClose];
                [encodedHTMLTags addObject:htmlTag];
            }
            
            if (![textColor isEqual:[self ab_defaultValueForAttribKey:kTextColorAttribKey]]) {
                htmlTag = [QGSpanTag tagWithType:QGTagFaceTypeOpen];
                [(QGSpanTag *)htmlTag setAttributeValue:textColor forAttribute:QGTagAttributeTextColorKey];
                [encodedHTMLTags addObject:htmlTag];
            }
        }
    }
    
    // Before returning tags, make sure all of them are in order by running it's rules. E.g. Closed tags come prior to open tags.
    return [encodedHTMLTags sortedArrayUsingSelector:@selector(compareOrderValue:)];
}

@end
