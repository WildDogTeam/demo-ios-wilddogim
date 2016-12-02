//
//  LoginViewController.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "LoginViewController.h"
#import "AddressListController.h"
#import "AuthenticationService.h"
#import "WDGDemoConstDefine.h"
#import "GroupInfoModel.h"
#import "UserInfoModel.h"
#import "GroupInfoDataBase.h"
#import "UserInfoDataBase.h"
#import <SVProgressHUD.h>

#import "WDGIMClient.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *chooseUserBtn;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"登录";
    
    self.chooseUserBtn.layer.borderWidth = 1;
    self.chooseUserBtn.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.loginBtn.layer.borderWidth = 1;
    self.loginBtn.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:80.0/255.0 blue:30.0/255.0 alpha:1].CGColor;
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)chooseLoginUser:(id)sender
{
    AddressListController *vc = [[AddressListController alloc] init];
    vc.fromOffline = YES;
    vc.selectedUserBlock = ^(NSString *selectedUser){
        [[NSUserDefaults standardUserDefaults] setObject:selectedUser forKey:kWildIMDemoUserDefaultUserUid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.chooseUserBtn setTitle:[NSString stringWithFormat:@"野狗%@号",selectedUser] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loginAction:(id)sender
{
    [SVProgressHUD showWithStatus:@"正在登录"];
    
    [[AuthenticationService sharedInstance] loginAppService:[Utility myUid] withCompletion:^(NSError *error, id result) {
        if (!error) {
            NSString *idToken = [[result objectForKey:@"data"]objectForKey:@"token"];
            
            //登录 Wilddog IM
            __block UserInfoModel *model = nil;
            [[WDGIMClient defaultClient] signInWithCustomToken:idToken completion:^(WDGIMUser * _Nullable authenticatedUser, NSError * _Nullable error) {
                if(!error){
                    [SVProgressHUD dismiss];
                    
                    [[WildIMKitSqlDataBase sharedInstance] initSqlPersistenceStorageEngineWithCacheId:@"imdemo"];
                    
                    model = [[UserInfoModel alloc]initWithDic:[[result objectForKey:@"data"]objectForKey:@"user"]];
                    [[UserInfoDataBase sharedInstance]saveUserInfo:model];
                    
                    if (model.userId) {
                        [[AuthenticationService sharedInstance]getFriendList:[Utility myUid] withCompletion:^(NSError *error, NSMutableArray *friendArray) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kWildNotificationConversationListUpdate object:nil userInfo:nil];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:@"登录失败"];
                }
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
