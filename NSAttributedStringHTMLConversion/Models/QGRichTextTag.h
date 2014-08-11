//
//  QGRichTextTag.h
//  NSAttributedStringHTMLConversion
//
//  Created by Matoria, Ashok on 7/21/14.
//  Copyright (c) 2014 iOSAppDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

// Tag face type
typedef NS_ENUM (NSUInteger, QGTagFaceType) {
    QGTagFaceTypeUnkown = 0,
    QGTagFaceTypeOpen,
    QGTagFaceTypeClose
};

// Sequence order for same face type (rather, use orderValue property)
typedef NS_ENUM (NSUInteger, QGTagSequenceOrder) {
    QGTagSequenceOrderBold = 1,
    QGTagSequenceOrderItalic,
    QGTagSequenceOrderUnderline,
    QGTagSequenceOrderSpan
};


@class QGTag;

// Abstract class
@interface QGTag : NSObject

@property(nonatomic, copy) NSString *tagValue;

// Designated initializer
+ (instancetype)tagWithType:(QGTagFaceType)type;

- (BOOL)isOpen;
- (BOOL)isClose;

// User the face type and QGTagSequenceOrder to determine the value
- (NSInteger)orderValue;

- (NSComparisonResult)compareOrderValue:(QGTag *)anotherObj;

@end

// Bold (<strong>)
@interface QGBoldTag : QGTag

@end

// Italic (<em>)
@interface QGItalicTag : QGTag

@end

// Underline (<u>)
@interface QGUnderlineTag : QGTag

@end


extern NSString *QGTagAttributeTextColorKey;

// Span <span> class to allow various attributes. Refer.
@interface QGSpanTag : QGTag

- (void)setAttributeValue:(id)value  forAttribute:(NSString *)attribute;

@end
