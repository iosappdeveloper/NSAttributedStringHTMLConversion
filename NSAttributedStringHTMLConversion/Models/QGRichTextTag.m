//
//  QGRichTextTag.m
//  NSAttributedStringHTMLConversion
//
//  Created by Matoria, Ashok on 7/21/14.
//  Copyright (c) 2014 iOSAppDeveloper. All rights reserved.
//

#import "QGRichTextTag.h"

NSString *kHTMLEncodeStringBoldBegin = @"<strong>";
NSString *kHTMLEncodeStringBoldEnd = @"</strong>";

NSString *kHTMLEncodeStringItalicBegin = @"<em>";
NSString *kHTMLEncodeStringItalicEnd = @"</em>";

NSString *kHTMLEncodeStringUnderlineBegin = @"<u>";
NSString *kHTMLEncodeStringUnderlineEnd = @"</u>";

NSString *kHTMLEncodeStringSpanBegin = @"<span>";
NSString *kHTMLEncodeStringSpanEnd = @"</span>";

#define kHTMLEncodeStringRBGColorBegin(r,g,b) ([NSString stringWithFormat:@"<span style=\"color:rgb(%d, %d, %d)\">", r,g,b])
#define kHTMLEncodeStringRBGColorClose (@"</span>")

#define kTagOrderBaseValue (100)

// Public span attribute keys
NSString *QGTagAttributeTextColorKey = @"TextColor";

@implementation QGTag

+ (instancetype)tagWithType:(QGTagFaceType)type
{
    QGTag *tag = [[QGTag alloc] initWithType:type];
    
    return tag;
}

- (instancetype)initWithType:(QGTagFaceType)faceType
{
    NSException *exception = [NSException exceptionWithName:@"Error" reason:@"Abstract class can not be instantiated." userInfo:nil];
    @throw exception;
    
    return nil;
}

- (BOOL)isOpen
{
    NSException *exception = [NSException exceptionWithName:@"Error" reason:@"Abstract class can not be instantiated." userInfo:nil];
    @throw exception;
    
    return NO;
}

- (BOOL)isClose
{
    NSException *exception = [NSException exceptionWithName:@"Error" reason:@"Abstract class can not be instantiated." userInfo:nil];
    @throw exception;
    
    return NO;
}

- (NSInteger)orderValue
{
    NSException *exception = [NSException exceptionWithName:@"Error" reason:@"Abstract class can not be instantiated." userInfo:nil];
    @throw exception;
    
    return 0;
    
}

- (NSComparisonResult)compareOrderValue:(QGTag *)anotherObj
{
    if (self.orderValue < anotherObj.orderValue) {
        return NSOrderedAscending;
    }
    else if (self.orderValue > anotherObj.orderValue) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"tagValue = %@ orderValue = %d", self.tagValue, [self orderValue]];
}

@end

@implementation QGBoldTag

+ (instancetype)tagWithType:(QGTagFaceType)type
{
    return [[QGBoldTag alloc] initWithType:type];
}

- (BOOL)isOpen
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringBoldBegin]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isClose
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringBoldEnd]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (instancetype)initWithType:(QGTagFaceType)faceType
{
    if (self = [super init]) {
        if (faceType == QGTagFaceTypeOpen) {
            self.tagValue = kHTMLEncodeStringBoldBegin;
        }
        else {
            self.tagValue = kHTMLEncodeStringBoldEnd;
        }
    }
    
    return self;
}

- (NSInteger)orderValue
{
    NSInteger order = kTagOrderBaseValue + (self.isOpen ? QGTagSequenceOrderBold : -QGTagSequenceOrderBold);

    return order;
}

@end

@implementation QGItalicTag

+ (instancetype)tagWithType:(QGTagFaceType)type
{
    return [[QGItalicTag alloc] initWithType:type];
}

- (BOOL)isOpen
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringItalicBegin]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isClose
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringItalicEnd]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (instancetype)initWithType:(QGTagFaceType)faceType
{
    if (self = [super init]) {
        if (faceType == QGTagFaceTypeOpen) {
            self.tagValue = kHTMLEncodeStringItalicBegin;
        }
        else {
            self.tagValue = kHTMLEncodeStringItalicEnd;
        }
    }
    
    return self;
}

- (NSInteger)orderValue
{
    NSInteger order = kTagOrderBaseValue + (self.isOpen ? QGTagSequenceOrderItalic : -QGTagSequenceOrderItalic);
    
    return order;
}

@end

@implementation QGUnderlineTag

+ (instancetype)tagWithType:(QGTagFaceType)type
{
    return [[QGUnderlineTag alloc] initWithType:type];
}

- (BOOL)isOpen
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringUnderlineBegin]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isClose
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringUnderlineEnd]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (instancetype)initWithType:(QGTagFaceType)faceType
{
    if (self = [super init]) {
        if (faceType == QGTagFaceTypeOpen) {
            self.tagValue = kHTMLEncodeStringUnderlineBegin;
        }
        else {
            self.tagValue = kHTMLEncodeStringUnderlineEnd;
        }
    }
    
    return self;
}

- (NSInteger)orderValue
{
    NSInteger order = kTagOrderBaseValue + (self.isOpen ? QGTagSequenceOrderUnderline : -QGTagSequenceOrderUnderline);

    return order;
}

@end

// Tag for text foreground color
@implementation QGSpanTag

+ (instancetype)tagWithType:(QGTagFaceType)type
{
    return [[QGSpanTag alloc] initWithType:type];
}

- (instancetype)initWithType:(QGTagFaceType)faceType
{
    if (self = [super init]) {
        if (faceType == QGTagFaceTypeClose) {
            self.tagValue = kHTMLEncodeStringRBGColorClose;
        }
    }
    
    return self;
}

- (void)setAttributeValue:(id)value  forAttribute:(NSString *)attribute
{
    if ([attribute isEqualToString:QGTagAttributeTextColorKey]) {
        NSAssert([value isKindOfClass:[UIColor class]], @"Should be a UIColor object");
        UIColor *color = (UIColor *)value;

        CGFloat redValue = 0;
        CGFloat greenValue = 0;
        CGFloat blueValue = 0;
        
        [color getRed:&redValue green:&greenValue blue:&blueValue alpha:nil];

        self.tagValue = kHTMLEncodeStringRBGColorBegin((int)(redValue * 255),
                                                       (int)(greenValue * 255),
                                                       (int)(blueValue *255));
    }
    else {
        NSAssert1(NO, @"Unexpected attribute key. Consider implementing this key - %@", attribute);
    }

}

- (BOOL)isOpen
{
    if (![self.tagValue isEqualToString:kHTMLEncodeStringRBGColorClose]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isClose
{
    if ([self.tagValue isEqualToString:kHTMLEncodeStringRBGColorClose]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSInteger)orderValue
{
    NSInteger order = kTagOrderBaseValue + (self.isOpen ? QGTagSequenceOrderSpan : -QGTagSequenceOrderSpan);

    return order;
}

@end
