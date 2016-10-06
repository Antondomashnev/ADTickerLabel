#import "ADTickerLabel.h"
#import <QuartzCore/QuartzCore.h>


@interface ADTickerCharacterLabel : UILabel

@property (nonatomic, copy) void(^animationDidCompleteBlock)(ADTickerCharacterLabel *label);

@end

@implementation ADTickerCharacterLabel

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
   if (self.animationDidCompleteBlock)
   {
      self.animationDidCompleteBlock(self);
   }
}

@end



@interface ADTickerLabel ()

@property (nonatomic, strong) NSMutableArray <ADTickerCharacterLabel *> *characterViews;
@property (nonatomic) CGFloat characterWidth;

@property (nonatomic, strong) UIView *charactersView;

@property (nonatomic, strong) NSMutableSet <ADTickerCharacterLabel *> *labelViewsToRemove;

@end

@implementation ADTickerLabel

#pragma mark - Initialization

- (void)initializeLabel
{
   self.characterViews = [NSMutableArray array];
   self.labelViewsToRemove = [NSMutableSet set];
   
   self.charactersView = [[UIView alloc] initWithFrame: self.bounds];
   self.charactersView.clipsToBounds = YES;
   self.charactersView.backgroundColor = [UIColor clearColor];
   [self addSubview: self.charactersView];

   self.font = [UIFont systemFontOfSize: 12.];
   self.textColor = [UIColor blackColor];
   self.animationDuration = 1.0;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder: aDecoder];
   if (self) {
      [self initializeLabel];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame: frame];
   if (self) {
      [self initializeLabel];
   }
   return self;
}


#pragma mark - Text Update

- (void)setText:(NSString *)text
{
   [self setText:text animated:YES];
}

- (void)setText:(NSString *)text
       animated:(BOOL)animated
{
   if ([_text isEqualToString: text])
   {
      return;
   }
   
   NSInteger oldTextLength = [_text length];
   NSInteger newTextLength = [text length];
   
   if (newTextLength > oldTextLength)
   {
      NSInteger textLengthDelta = newTextLength - oldTextLength;
      for (NSInteger i = 0 ; i < textLengthDelta; ++i)
      {
         [self insertNewCharacterLabel];
      }
      [self invalidateIntrinsicContentSize];
      [self setNeedsLayout];
      [self layoutCharacterLabels];
   }
   else if (newTextLength < oldTextLength)
   {
      NSInteger textLengthDelta = oldTextLength - newTextLength;
      for (NSInteger i = 0 ; i < textLengthDelta; ++i)
      {
         [self removeLastCharacterLabel:animated];
      }
      
      if (!animated)
      {
         [self invalidateIntrinsicContentSize];
         [self setNeedsLayout];
         [self layoutCharacterLabels];
      }
   }
   
   [self.characterViews enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       NSString *character = [text substringWithRange:NSMakeRange(idx, 1)];
       NSString *oldCharacter = label.text;
       
       label.text = character;
       
       if (animated && ![oldCharacter isEqualToString:character])
       {
          // add basic animation to view
          NSInteger oldValue = oldCharacter.integerValue;
          NSInteger newValue = character.integerValue;
          
          // jump from 9 to 0 should be animated in the correct direction
          if (oldValue == 9 && newValue != 8)
          {
             [self addLabelAnimation:label direction:ADTickerLabelScrollDirectionDown];
          }
          // jump from 0/1 to 9 should be animated in the correct direction
          else if ((oldValue == 0 || oldValue == 1) && newValue == 9)
          {
             [self addLabelAnimation:label direction:ADTickerLabelScrollDirectionUp];
          }
          else if (oldValue > newValue)
          {
             [self addLabelAnimation:label direction:ADTickerLabelScrollDirectionUp];
          }
          else if (oldValue < newValue)
          {
             [self addLabelAnimation:label direction:ADTickerLabelScrollDirectionDown];
          }
          else
          {
             [self addLabelAnimation:label direction:ADTickerLabelScrollDirectionDown];
          }
       }
    }];
   
   _text = text;
}

#pragma mark - Character Animation

- (void)addLabelAnimation:(UILabel *)label direction:(ADTickerLabelScrollDirection)scrollDirection
{
   [self addLabelAnimation:label direction:scrollDirection notifyDelegate:NO];
}

- (CATransition *)addLabelAnimation:(UILabel *)label direction:(ADTickerLabelScrollDirection)scrollDirection notifyDelegate:(BOOL)notifyDelegate
{
   // inverse the scrolldirection, if the direction is going up
   if (self.scrollDirection == ADTickerLabelScrollDirectionUp)
   {
      scrollDirection = !scrollDirection;
   }
   
   CATransition *transition = [CATransition animation];
   
   transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
   transition.duration = self.animationDuration;
   transition.type = kCATransitionPush;
   
   transition.subtype = scrollDirection == ADTickerLabelScrollDirectionUp ? kCATransitionFromTop : kCATransitionFromBottom;
   
   if (notifyDelegate)
   {
      transition.delegate = label;
   }
   
   [label.layer addAnimation:transition forKey:nil];
   
   return transition;
}

#pragma mark - Character Labels

- (void)insertNewCharacterLabel
{
   CGRect characterFrame = CGRectZero;
   
   characterFrame.size = CGSizeMake(self.characterWidth, self.bounds.size.height);
   
   ADTickerCharacterLabel *characterLabel = [[ADTickerCharacterLabel alloc] initWithFrame: characterFrame];
   characterLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
   characterLabel.textAlignment = NSTextAlignmentCenter;
   characterLabel.font = self.font;
   characterLabel.textColor = self.textColor;
   characterLabel.shadowColor = self.shadowColor;
   characterLabel.shadowOffset = self.shadowOffset;
   
   [self.charactersView addSubview:characterLabel];
   
   [self.characterViews addObject:characterLabel];
}

- (void)removeLastCharacterLabel:(BOOL)animated
{
   ADTickerCharacterLabel *label = nil;
   
   if (self.textAlignment == NSTextAlignmentRight)
   {
      label = self.characterViews.firstObject;
   }
   else
   {
      label = self.characterViews.lastObject;
   }
   
   [self.characterViews removeObject:label];
   
   if (animated)
   {
      label.text = nil;
      
      [self.labelViewsToRemove addObject:label];
      
      __weak typeof(self) weakSelf = self;
      [label setAnimationDidCompleteBlock:^(ADTickerCharacterLabel *label) {
         [weakSelf labelDidCompleteRemovealAnimation:label];
      }];
      
      [self addLabelAnimation:label direction:ADTickerLabelScrollDirectionUp notifyDelegate:YES];
   }
   else
   {
      [label removeFromSuperview];
   }
}

-(void)labelDidCompleteRemovealAnimation:(ADTickerCharacterLabel *)label
{
   [label removeFromSuperview];
   [self.labelViewsToRemove removeObject:label];
   
   if (self.labelViewsToRemove.count == 0)
   {
      [self layoutCharacterLabels];
      [self invalidateIntrinsicContentSize];
      [self setNeedsLayout];
   }
}


#pragma mark - Layouting

- (void)layoutSubviews
{
   [super layoutSubviews];
   
   if ([self.characterViews count] > 0)
   {
      self.charactersView.frame = [self characterViewFrameWithContentBounds: self.bounds];
   }
}

- (CGRect)characterViewFrameWithContentBounds:(CGRect)frame
{
   CGFloat charactersWidth = [self.characterViews count] * self.characterWidth;
   frame.size.width = charactersWidth;

   switch (self.textAlignment)
   {
      case NSTextAlignmentRight:
         frame.origin.x = self.frame.size.width - charactersWidth;
         break;
      case NSTextAlignmentCenter:
         frame.origin.x = (self.frame.size.width - charactersWidth) / 2;
         break;
      case NSTextAlignmentLeft:
      default:
         frame.origin.x = 0.0;
         break;
   }
   
   return frame;
}

- (void)layoutCharacterLabels
{
   CGRect characterFrame = CGRectZero;
   for (UILabel* label in self.characterViews)
   {
      characterFrame.size.height = CGRectGetHeight(self.charactersView.bounds);
      characterFrame.size.width = self.characterWidth;
      label.frame = characterFrame;
      
      characterFrame.origin.x += self.characterWidth;
   }
}

- (CGSize)intrinsicContentSize
{
   return CGSizeMake(self.characterWidth * self.text.length, UIViewNoIntrinsicMetric);
}


#pragma mark - Text Appearance

- (void)setShadowOffset:(CGSize)shadowOffset
{
   _shadowOffset = shadowOffset;
   [self.characterViews enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       label.shadowOffset = shadowOffset;
    }];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
   _shadowColor = shadowColor;
   [self.characterViews enumerateObjectsUsingBlock:
    ^(UILabel *label, NSUInteger idx, BOOL *stop)
    {
       label.shadowColor = shadowColor;
    }];
}

- (void)setTextColor:(UIColor *)textColor
{
   if (![_textColor isEqual: textColor])
   {
      _textColor = textColor;
      [self.characterViews enumerateObjectsUsingBlock:
       ^(UILabel *label, NSUInteger idx, BOOL *stop)
       {
          label.textColor = textColor;
       }];
   }
}

- (void)setFont:(UIFont *)font
{
   if (![_font isEqual: font])
   {
      _font = font;
      self.characterWidth = [@"8" sizeWithAttributes:@{NSFontAttributeName: font}].width;
      
      [self.characterViews enumerateObjectsUsingBlock:
       ^(UILabel *label, NSUInteger idx, BOOL *stop)
       {
          label.font = self.font;
       }];
      
      [self setNeedsLayout];
      [self invalidateIntrinsicContentSize];
   }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
   _textAlignment = textAlignment;
   [self setNeedsLayout];
}

@end
