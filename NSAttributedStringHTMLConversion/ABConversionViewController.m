//
//  ABConversionViewController.m
//  NSAttributedStringHTMLConversion
//
//  Created by Matoria, Ashok on 8/11/14.
//  Copyright (c) 2014 iOSAppDeveloper. All rights reserved.
//

#import "ABConversionViewController.h"

#import "NSAttributedString+HTML.h"

@interface ABConversionViewController ()
@property (weak, nonatomic) IBOutlet UITextView *htmlTextView;
@property (weak, nonatomic) IBOutlet UITextView *richTextView;
@property (weak, nonatomic) IBOutlet UIButton *richTextBtn;
@property (weak, nonatomic) IBOutlet UIButton *htmlBtn;

@end

@implementation ABConversionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)convertActionWithBtn:(UIButton *)sender
{
    if ([sender isEqual:self.htmlBtn]) {    // To HTML

        if (self.richTextView.text.length > 0) {
            self.htmlTextView.text = [self.richTextView.attributedText ab_encodedHTMLString];
        }

    }
    else if ([sender isEqual:self.richTextBtn]) { // To Rich text
        NSString *htmlText = self.htmlTextView.text;

        if (htmlText.length > 0) {
            // Generate attributed string from plain HTML
            NSAttributedString *attribText = [[NSAttributedString alloc] initWithData:[htmlText dataUsingEncoding:NSUTF16StringEncoding]
                                                                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                                                 documentAttributes:nil error:nil];

            self.richTextView.attributedText = attribText;
        }
        
    }
}

@end
