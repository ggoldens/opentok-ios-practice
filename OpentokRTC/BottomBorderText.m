//
//  BottomBorderText.m
//  OpentokRTC
//
//  Created by Andrea Phillips on 14/09/2015.
//  Copyright (c) 2015 Agilityfeat. All rights reserved.
//

#import "BottomBorderText.h"

@implementation BottomBorderText

UIView *separatorView;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self postInitialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self postInitialization];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self postInitialization];
}


- (void)postInitialization {
    self.backgroundColor = [UIColor clearColor];
    CGRect frame =[separatorView frame];
    frame.size.height=2.0f;
    [separatorView setFrame:frame];
    separatorView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [self addSubview:separatorView];
}


#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat onePixelHeight = 1.0f / [[UIScreen mainScreen] scale];
    
    separatorView.frame = CGRectMake(0, height, width, onePixelHeight);
}

@end
