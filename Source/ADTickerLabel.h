//
//  ADTickerLabel.h
//  ADTickerLabel
//
//  Created by Anton Domashnev on 28.05.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADTickerLabel : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

/*
 Default 8 px
 */
@property (nonatomic, unsafe_unretained) float characterWidth;

/*
 Frame may have been changed after setting new text
 */
@property (nonatomic, strong) NSString *text;

@end
