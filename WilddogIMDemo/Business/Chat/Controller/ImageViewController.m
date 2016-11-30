//
//  ImageViewController.m
//  WilddogIM
//
//  Created by Garin on 16/7/19.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma initViewController

- (id)initViewController:(UIImage*)image
{
    willShowImage = image;
    imageView = nil;
    bIsSendOriPic = FALSE;
    
    [self initImageView];
    [self layoutViews];
    [self setupBottomToorBar];
    
    return  self;
}

- (void)initImageView{
    
    if (nil == imageView) {
        imageView = [[UIImageView alloc] initWithImage:willShowImage];
        imageView.userInteractionEnabled  = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGestureRecognizer)];
        [imageView addGestureRecognizer:tapGesture];
    }
}

- (void)layoutViews{
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44);
}

- (void) setupBottomToorBar{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    toolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolBar];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toolBar);
    NSString *widthVfl =  @"H:|-0-[toolBar]-0-|";
    NSString *heightVfl = @"V:[toolBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.createOriPicRadioBtn];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.createSendBtn];
    
    toolBar.items = @[leftItem,rightItem];
}

-(UIButton *)createOriPicRadioBtn{
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-100, 20)];
    
    UIButton *oriPicRadioBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    oriPicRadioBtn.frame = CGRectMake(0, 0, 20, 20);
    CALayer * layer = [oriPicRadioBtn layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10.0];
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
    [oriPicRadioBtn setImage:[UIImage imageNamed:@"chat_group_selected"] forState:UIControlStateSelected];
    [oriPicRadioBtn addTarget:self action:@selector(OnOriPicClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(25, 0, 150, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self calImageSize];
    
    [container addSubview:oriPicRadioBtn];
    [container addSubview:label];
    
    [self.view addSubview:container];
    return (UIButton*)container;
}

-(NSString *)calImageSize{
    NSData *imageData = UIImageJPEGRepresentation(willShowImage, 1);
    
    CGFloat length = [imageData length];
    int loopNum = 0;//图片单位 0->B,1->KB,2->MB,3->GB
    while(TRUE){
        if (length >= 1024) {
            length /= 1024.0;
        }
        else{
            break;
        }
        loopNum++;
    }
    NSString *imageUnit;
    switch (loopNum) {
        case 0:
            imageUnit = @"B";
            break;
        case 1:
            imageUnit = @"KB";
            break;
        case 2:
            imageUnit = @"MB";
            break;
        case 3:
            imageUnit = @"GB";
            break;
        default:
            imageUnit = @"";
            break;
    }
    
    NSString *strSize = [[NSString alloc] initWithFormat:@"原图(%.2f%@)",length,imageUnit];
    return strSize;
}

- (UIButton *)createSendBtn{
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:80.0/255.0 blue:30.0/255.0 alpha:1]];
    sendBtn.enabled = YES;
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    sendBtn.frame = CGRectMake(0, 0, 60, 30);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(OnSendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return sendBtn;
}

#pragma mark - click事件响应
- (void)didTapGestureRecognizer
{
    if (nil != self.navigationController && 1 < [self.navigationController.viewControllers count]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [self releaseImageView];
}

- (void)OnOriPicClick:(id)sender{
    NSLog(@"click_ok");
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if (button.state == UIControlStateNormal) {
        bIsSendOriPic = FALSE;
    }
    else{
        bIsSendOriPic = TRUE;
    }
}

- (void)OnSendBtnClick:(id)sender{
    [self.delegate sendImageAction:willShowImage isSendOriPic:bIsSendOriPic];
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate releasePicker];
}

- (void)releaseImageView{
    willShowImage = nil;
    imageView = nil;
    bIsSendOriPic = FALSE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
