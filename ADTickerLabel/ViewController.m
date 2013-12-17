//
//  ViewController.m
//  ADTickerLabel
//
//  Created by Anton Domashnev on 28.05.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "ViewController.h"
#import "ADTickerLabel.h"

@interface ViewController ()

@property (nonatomic, strong) ADTickerLabel *tickerLabel;
@property (nonatomic, strong) NSArray *numbersArray;
@property (nonatomic, unsafe_unretained) NSInteger currentIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.currentIndex = 0;
    self.numbersArray = @[@1, @29, @1098.7, @89, @18741984, @897];
    
    UIFont *font = [UIFont boldSystemFontOfSize: 12];
    
    self.tickerLabel = [[ADTickerLabel alloc] initWithFrame: CGRectMake(50, 50, 100, font.lineHeight)];
    self.tickerLabel.font = font;
    self.tickerLabel.characterWidth = 8;
    self.tickerLabel.changeTextAnimationDuration = 0.5;
    self.tickerLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview: self.tickerLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender{
    
    self.tickerLabel.text = [NSString stringWithFormat:@"%@", self.numbersArray[self.currentIndex]];
    
    self.currentIndex++;
    if(self.currentIndex == [self.numbersArray count]) self.currentIndex = 0;
}

@end
