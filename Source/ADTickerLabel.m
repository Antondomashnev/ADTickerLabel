//
//  ADTickerLabel.m
//  ADTickerLabel
//
//  Created by Anton Domashnev on 28.05.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "ADTickerLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface ADTickerCharacterView : UIView

@property (nonatomic, strong) NSArray *charactersArray;
@property (nonatomic, strong) NSString *selectedCharacter;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, unsafe_unretained) NSInteger selectedCharacterIndex;

- (void)setSelectedCharacter:(NSString *)selectedCharacter animated:(BOOL)animated;
- (id)initWithFrame:(CGRect)frame textLabel:(UILabel *)textLabel;

@end

@implementation ADTickerCharacterView

@synthesize charactersArray = _charactersArray;
@synthesize selectedCharacter = _selectedCharacter;
@synthesize textLabel = _textLabel;

- (id)initWithFrame:(CGRect)frame textLabel:(UILabel *)textLabel{
    
    if(self = [super initWithFrame: frame]){
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel = textLabel;
        [self addSubview: textLabel];
    }
    
    return self;
}

- (void)setCharactersArray:(NSArray *)charactersArray{
    
    _charactersArray = charactersArray;
    
    NSMutableString *string = [NSMutableString string];
    for(int i = 0; i < [charactersArray count]; i++){
        
        [string appendString: charactersArray[i]];
        
        if(i != ([charactersArray count] - 1)){
            [string appendString: @"\n"];
        }
    }
    
    self.textLabel.text = string;
}

- (CGFloat)positionYForCharacterAtIndex:(NSInteger)index{
    
    return -index * (self.textLabel.frame.size.height / [self.charactersArray count]);
}

- (void)animateToPositionY:(CGFloat)positionY withCallback:(void(^)(void))callback{
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = positionY;
    
    [UIView animateWithDuration:1 animations:^{
        self.frame = newFrame;
    } completion:^(BOOL finished) {
        
        callback();
    }];
}

- (void)setSelectedCharacter:(NSString *)selectedCharacter animated:(BOOL)animated{
    
    NSInteger selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter];
    
    if(selectedCharacterIndex > self.selectedCharacterIndex){
        
        [self animateToPositionY:[self positionYForCharacterAtIndex: selectedCharacterIndex] withCallback:^{
            self.selectedCharacter = selectedCharacter;
            self.selectedCharacterIndex = selectedCharacterIndex;
        }];
    }
    else if(selectedCharacterIndex < self.selectedCharacterIndex){
        
        //We try to find the chatracter in secod part of array
        for(int i = [self.charactersArray count] / 2; i < [self.charactersArray count]; i++){
            
            if([self.charactersArray[i] isEqualToString: selectedCharacter]){
                selectedCharacterIndex = i;
                break;
            }
        }
        
        [self animateToPositionY:[self positionYForCharacterAtIndex: selectedCharacterIndex] withCallback:^{
            self.selectedCharacter = selectedCharacter;
            self.selectedCharacterIndex = [self.charactersArray indexOfObject: selectedCharacter];
            
            CGRect newFrame = self.frame;
            newFrame.origin.y = [self positionYForCharacterAtIndex: self.selectedCharacterIndex];
            self.frame = newFrame;
        }];
    }
}

@end

@interface ADTickerLabel()

@property (nonatomic, strong) NSMutableArray *characterViewsArray;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation ADTickerLabel

@synthesize text = _text;
@synthesize font = _font;
@synthesize characterWidth = _characterWidth;
@synthesize textColor = _textColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.characterWidth = 8.f;
        self.font = [UIFont systemFontOfSize: 12.];
        self.textColor = [UIColor blackColor];
        self.characterViewsArray = [NSMutableArray array];
        
        [self addMaskLayer];
    }
    return self;
}

#pragma mark MaskLayer

- (CGRect)maskLayerFrame{
    
    CGRect frame = CGRectZero;
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.size.height = self.font.lineHeight;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    return frame;
}

- (void)updateMaskLayerPath{
    
    CGPathRef path = CGPathCreateWithRect([self maskLayerFrame], NULL);
    self.maskLayer.path = path;
    CGPathRelease(path);
}

- (void)addMaskLayer{
    
    self.maskLayer = [CAShapeLayer layer];
    
    CGPathRef path = CGPathCreateWithRect([self maskLayerFrame], NULL);
    self.maskLayer.path = path;
    CGPathRelease(path);
    
    [self.maskLayer setFillColor: [UIColor redColor].CGColor];
    [self.layer setMask: self.maskLayer];
}

#pragma mark ADTickerCharacterView

- (void)insertNewTickerCharacterView{
    
    NSArray *charactersArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];

    CGRect newTextLabelBounds = CGRectZero;
    newTextLabelBounds.origin = CGPointZero;
    newTextLabelBounds.size = CGSizeMake(self.characterWidth, self.font.lineHeight * [charactersArray count]);
    UILabel *textLabel = [[UILabel alloc] initWithFrame:newTextLabelBounds];
    textLabel.font = self.font;
    textLabel.textAlignment = UITextAlignmentRight;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = self.textColor;
    textLabel.numberOfLines = 0;
    
    CGRect tickerCharacterViewFrame = self.bounds;
    tickerCharacterViewFrame.size.height = newTextLabelBounds.size.height;
    ADTickerCharacterView *numbericView = [[ADTickerCharacterView alloc] initWithFrame:tickerCharacterViewFrame textLabel: textLabel];
    numbericView.selectedCharacter = @"0";
    numbericView.selectedCharacterIndex = 0;
    numbericView.charactersArray = charactersArray;
    
    [self addSubview: numbericView];
    
    [self.characterViewsArray addObject: numbericView];
}

- (void)deleteCharacterView{
    
    ADTickerCharacterView *numericView = [self.characterViewsArray objectAtIndex:0];
    [numericView removeFromSuperview];
    [self.characterViewsArray removeObject: numericView];
}

#pragma mark Frames

- (void)updateSELFFrame{
    
    CGRect newViewFrame = self.frame;
    newViewFrame.size.width = [self.characterViewsArray count] * self.characterWidth;
    newViewFrame.origin.x += self.frame.size.width - newViewFrame.size.width;
    self.frame = newViewFrame;
}

- (void)updateTickerCharacterViewsFrames{
    
    __block float originX = 0;
    [self.characterViewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIView *numericView = (UIView *)obj;
        
        CGRect numericViewFrame = numericView.frame;
        numericViewFrame.origin.x = originX;
        numericViewFrame.origin.y = 0;
        numericViewFrame.size.width = self.characterWidth;
        numericView.frame = numericViewFrame;
        
        originX += self.characterWidth;
    }];
}

- (void)updateUIFrames{
    
    [self updateSELFFrame];
    [self updateMaskLayerPath];
    [self updateTickerCharacterViewsFrames];
}

#pragma mark Fonts

- (void)updateTickerCharacterViewsFont{
    
    [self.characterViewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UILabel *tickerCharacterTextLabel = ((ADTickerCharacterView *)obj).textLabel;
        tickerCharacterTextLabel.font = self.font;
    }];
}

- (void)updateTickerCharacterViewsTextColor{
    
    [self.characterViewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UILabel *tickerCharacterTextLabel = ((ADTickerCharacterView *)obj).textLabel;
        tickerCharacterTextLabel.textColor = self.textColor;
    }];
}

#pragma mark Interface

- (void)setTextColor:(UIColor *)textColor{
    
    if(![_textColor isEqual: textColor]){
        
        _textColor = textColor;
        
        [self updateTickerCharacterViewsTextColor];
    }
}

- (void)setFont:(UIFont *)font{
    
    if(![_font isEqual: font]){
        
        _font = font;
        
        [self updateUIFrames];
    }
}

- (void)setCharacterWidth:(float)characterWidth{
    
    if(_characterWidth != characterWidth){
        
        _characterWidth = characterWidth;
        
        [self updateUIFrames];
    }
}

- (void)setText:(NSString *)text{
    
    if(![_text isEqualToString: text]){
        
        NSInteger oldTextLength = [_text length];
        NSInteger newTextLength = [text length];
        
        if(newTextLength > oldTextLength){
            
            NSInteger textLengthDelta = newTextLength - oldTextLength;
            for(int i = 0 ; i < textLengthDelta; i++){
                
                [self insertNewTickerCharacterView];
            }
            
            [self updateUIFrames];
        }
        else if(newTextLength < oldTextLength){
            
            NSInteger textLengthDelta = oldTextLength - newTextLength;
            
            for(int i = 0 ; i < textLengthDelta; i++){
                
                [self deleteCharacterView];
            }
            
            [self updateUIFrames];
        }
        
        [self.characterViewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            ADTickerCharacterView *numericView = (ADTickerCharacterView *)obj;
            [numericView setSelectedCharacter:[text substringWithRange:NSMakeRange(idx, 1)] animated:YES];
        }];
        
        _text = text;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
