//
//  AppDelegate.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ConversationListController.h"
#import "AddressListController.h"
#import "ConversationViewController.h"

#import "MsgBaseModel.h"
#import "UserInfoDataBase.h"
#import "GroupInfoDataBase.h"
#import "GroupInfoModel.h"

#import <WilddogIM/WilddogIM.h>

#define WilddogAppID @"wdimdemo"

@import Wilddog;
@interface AppDelegate () <UISplitViewControllerDelegate, WDGIMClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //使用第一步
    [WDGIMClient clientWithAppID:WilddogAppID delegate:self];
    
    [[NSUserDefaults standardUserDefaults] setObject:WilddogAppID forKey:kWildIMDemoUserDefaultWilddogAppID];
    [[NSUserDefaults standardUserDefaults] synchronize];

    ConversationListController *convVC = [[ConversationListController alloc]init];
    AddressListController *addressVC = [[AddressListController alloc]init];

    UINavigationController *convNav = [[UINavigationController alloc]initWithRootViewController:convVC];
    UINavigationController *addressNav = [[UINavigationController alloc]initWithRootViewController:addressVC];
    
    UIImage *image = [Utility imageWithColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1] andSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 64.f)];
    [convNav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [addressNav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    convNav.navigationBar.tintColor = [UIColor colorWithRed:76/255.0 green:80/255.0 blue:80/255.0 alpha:1];
    addressNav.navigationBar.tintColor = [UIColor colorWithRed:76/255.0 green:80/255.0 blue:80/255.0 alpha:1];
    
    UITabBarItem *convBar = [[UITabBarItem alloc]initWithTitle:@"消息" image:[UIImage imageNamed:@"tab_recents_nor"] selectedImage:[UIImage imageNamed:@"tab_recents_pressed"]];
    UITabBarItem *addressBar = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageNamed:@"tab_contact_nor"] selectedImage:[UIImage imageNamed:@"tab_contact_pressed"]];
    
    convNav.tabBarItem = convBar;
    addressNav.tabBarItem = addressBar;
    
    UITabBarController *tabVC = [[UITabBarController alloc]init];
    tabVC.viewControllers = @[convNav,addressNav];
    
    self.window.rootViewController = tabVC;
    [self.window makeKeyAndVisible];
    
    if ([UIDevice currentDevice].systemVersion.intValue >= 8) { // iOS8+ API.
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else { // iOS7.
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[WDGIMClient defaultClient] updateRemoteNotificationDeviceToken:deviceToken error:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

//会接收来自苹果服务器给你返回的deviceToken，然后你需要将它添加到你本地的推送服务器上。（很重要，决定你的设备能不能接收到推送消息）。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSLog(@"userInfo = %@",userInfo);
    if (userInfo[@"apns"]) {
        if([ConversationListController current]){
            [Utility shareInstance].fromPush = YES;
        }
    }
}

#pragma mark - Delegate
- (void)wilddogIMClient:(WDGIMClient *)client didRecieveMessages:(NSArray<WDGIMMessage *> *)messages
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kWildNotificationConversationVCUpdate object:nil userInfo:@{@"msgs":messages}];
    [[NSNotificationCenter defaultCenter]postNotificationName:kWildNotificationConversationListUpdate object:nil];
}

- (void)wilddogIMClient:(WDGIMClient *)client didGroupInfoChange:(NSArray<WDGIMMessageGroupTip *> *)groupTips
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kWildNotificationConversationVCUpdate object:nil userInfo:@{@"msgs":groupTips}];
    [[NSNotificationCenter defaultCenter]postNotificationName:kWildNotificationConversationListUpdate object:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[WDGIMClient defaultClient] connectWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
        
    [[WDGIMClient defaultClient] disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
