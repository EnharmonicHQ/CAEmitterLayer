//
//  ENHViewController.m
//  EmissionsTest
//
//  Created by Jonathan Saggau on 3/22/13.
//  Copyright (c) 2013 Enharmonic. All rights reserved.
//

#import "ENHViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ENHViewController ()

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, weak) CAEmitterLayer *emitter;
@property (nonatomic, copy) NSString *imageName;
@end

@implementation ENHViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    CALayer *myLayer = [self.view layer];
    NSUInteger smokeNumber = 15;
    NSString *imageName = [NSString stringWithFormat:@"smoke%d", smokeNumber];
    [self setImageName:imageName];
    UIImage *image = [UIImage imageNamed:imageName];
    assert(image);

    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    [cell setName:imageName];
    float defaultBirthRate = 30.0f;
    float birthRateMin = 1.0f;
    float birthRateMax = 100.0f;
	[self.slider setMinimumValue:birthRateMin];
    [self.slider setMaximumValue:birthRateMax];
    [self.slider setValue:defaultBirthRate animated:NO];
    [self.label setText:[NSString stringWithFormat:@"%4.2f", defaultBirthRate]];
    [cell setBirthRate:defaultBirthRate];
    [cell setVelocity:120];
    [cell setVelocityRange:40];
    [cell setYAcceleration:-45.0f];
    [cell setEmissionLongitude:-M_PI_2];
    [cell setEmissionRange:M_PI_4];
    [cell setScale:1.0f];
    [cell setScaleSpeed:2.0f];
    [cell setScaleRange:2.0f];
    [cell setContents:(id)image.CGImage];
    [cell setColor:[UIColor colorWithRed:1.0 green:0.2 blue:0.1 alpha:0.5].CGColor];


    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [cell setLifetime:6.0f];
        [cell setLifetimeRange:2.0f];
    }
    else
    {
        [cell setLifetime:3.0f];
        [cell setLifetimeRange:1.0f];
    }

    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    [emitter setEmitterCells:@[cell]];
    CGRect bounds = [self.view bounds];
    [emitter setFrame:bounds];
    CGPoint emitterPosition = (CGPoint) {bounds.size.width*0.5f, bounds.size.height*0.5f};
    [emitter setEmitterPosition:emitterPosition];
    [emitter setEmitterSize:(CGSize){10.0f, 10.0f}];
    [emitter setEmitterShape:kCAEmitterLayerRectangle];
    [emitter setRenderMode:kCAEmitterLayerAdditive];
    [myLayer addSublayer:emitter];
    [self setEmitter:emitter];


    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognize:)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

-(void)recognize:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.view];
    NSString *animationKey = @"position";
    CGFloat duration = 1.0f;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"emitterPosition"];
    CAEmitterLayer *presentation = (CAEmitterLayer*)[self.emitter presentationLayer];
    CGPoint currentPosition = [presentation emitterPosition];
    [animation setFromValue:[NSValue valueWithCGPoint:currentPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:location]];
    [animation setDuration:duration];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    [self.emitter addAnimation:animation forKey:animationKey];
}

- (IBAction)sliderChanged:(id)sender
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), sender);
    float value = [(UISlider *)sender value];
    [self.label setText:[NSString stringWithFormat:@"%4.2f", value]];
    NSString *keyPath = [NSString stringWithFormat:@"emitterCells.%@.birthRate", self.imageName];
    [self.emitter setValue:@(value) forKeyPath:keyPath];
}

@end
