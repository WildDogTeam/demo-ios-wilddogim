//
//  ConversationListController.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ConversationListController.h"
#import "ConversationViewController.h"
#import "LoginViewController.h"
#import "MyUIDefine.h"
#import "ConversationListModel.h"
#import "ConversationListCell.h"
#import "MsgBaseModel.h"
#import "UserInfoDataBase.h"
#import "UserInfoModel.h"
#import "AddToGroupController.h"
#import "GroupInfoDataBase.h"
#import "GroupInfoModel.h"
#import "AppDelegate.h"
#import "StitchingImage.h"
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>

#import "WDGIMClient.h"

static ConversationListController *gCurrentConversationListController;

@interface ConversationListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) WDGIMClient *wildClient;
@property (nonatomic, retain) UserInfoModel *userModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* recentChatList;
@property (nonatomic, retain) NSString *groupName;
@end

@implementation ConversationListController

+ (ConversationListController *)current
{
    return gCurrentConversationListController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    gCurrentConversationListController = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    gCurrentConversationListController = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![Utility shareInstance].fromPush) {
        [self presentLoginVC];
    }
    
    self.title = @"消息";
    self.recentChatList = [NSMutableArray arrayWithCapacity:50];
    self.wildClient = [WDGIMClient defaultClient];

    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    [self.tableView setTableFooterView:view];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecentList) name:kWildNotificationConversationListUpdate object:nil];
    [self reloadRecentList];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"登出" style:UIBarButtonItemStylePlain target:self action:@selector(loginOut:)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAction:)]];
}

- (void)loginOut:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"确定要退出登录吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *corfim = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[WDGIMClient defaultClient] signOut:nil];
        [self presentLoginVC];
    }];
    [alertController addAction:cancel];
    [alertController addAction:corfim];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)presentLoginVC
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    UIImage *image = [Utility imageWithColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1] andSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 64.f)];
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    nav.navigationBar.tintColor = [UIColor colorWithRed:76/255.0 green:80/255.0 blue:80/255.0 alpha:1];
    
    [self presentViewController:nav animated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kWildIMDemoUserDefaultUserUid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)moreAction:(id)sender
{
    [self createGroup];
}

- (void)createGroup
{
    AddToGroupController *vc = [[AddToGroupController alloc]init];
    vc.groupName = self.groupName;
    vc.lastVC = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Load Data

- (void)reloadRecentList
{
    [self.recentChatList removeAllObjects];
    
    NSArray *conversations = [self.wildClient getConversations];
    int cnt = (int)[conversations count];
    for (int index = 0; index < cnt; index++) {
        WDGIMConversation *conversation = [conversations objectAtIndex:index];
        ConversationListModel* model = [self modelFromConversation:conversation];
        if (model.conversationId.length > 0) {
            [self.recentChatList addObject:model];
        }
    }
    [self.tableView reloadData];
}

- (ConversationListModel *)modelFromConversation:(WDGIMConversation *)conversation
{
    ConversationListModel *model = [[ConversationListModel alloc] init];
    model.groupAvatars = [NSMutableArray new];
    model.groupNames = [NSMutableArray new];
    
    model.unreadCount = conversation.totalNumberOfUnreadMessages;
    model.conversationId = conversation.conversationId;

    int type = MsgType_User;
    if ([conversation.conversationId containsString:@"-"]) {
        type = MsgType_User;
    }else{
        type = MsgType_Group;
    }
    model.type = type;
    
    if (model.type == MsgType_User) {
        UserInfoModel *user = [[UserInfoDataBase sharedInstance] getUserInfo:[Utility getOtherId:conversation.conversationId]];
        model.title = user.name;
        model.avatar = user.avatar;
        model.avatarImageView = nil;
        
    }else if(model.type == MsgType_Group){
        [conversation.members enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UserInfoModel *user = [[UserInfoDataBase sharedInstance] getUserInfo:obj];
            [model.groupNames addObject:user.name];
            [model.groupAvatars addObject:user.avatar];
        }];
        model.title = [model.groupNames componentsJoinedByString:@","];
        model.avatar = nil;
        
        UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        canvasView.layer.cornerRadius = 50 / 10;
        canvasView.layer.masksToBounds = YES;
        canvasView.backgroundColor = [UIColor colorWithWhite:0.839 alpha:1.000];
        UIImageView *imageView =  [self createImageViewWithCanvasView:canvasView withImageViews:model.groupAvatars];
        model.avatarImageView = imageView;
    }
    model.latestTimestamp = [self getDateWithTimestamp:[NSString stringWithFormat:@"%lld",conversation.lastMessage.sentAt]];
    //递归获取最近一条未被删除的消息
    int getMessageNum=1;
    [self getDetailInfo:conversation getMessageNum:getMessageNum lastMsg:nil listModel:model];

    return model;
}

- (UIImageView *)createImageViewWithCanvasView:(UIImageView *)canvasView withImageViews:(NSArray *)array
{
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    int count;
    if (array.count>9) {
        count = 9;
    }else{
        count = (int)array.count;
    }
    for (int index = 0; index < count; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:array[index]] placeholderImage:[UIImage imageNamed:@"Icon.png"]];
        [imageViews addObject:imageView];
    }
    
    return [[StitchingImage alloc] stitchingOnImageView:canvasView withImageViews:imageViews];
}


- (void)getDetailInfo:(WDGIMConversation *)conversation getMessageNum:(int)getMsgNum lastMsg:(WDGIMMessage *)last listModel:(ConversationListModel *)model {
    
    //获取最后一条消息
    NSArray *msgArray = [conversation getMessageFromLast:last limit:1];
    if(msgArray.count > 0){
        WDGIMMessage *msg = [msgArray lastObject];
        if ([msg isKindOfClass:[WDGIMMessageText class]]) {
            model.detailInfo = ((WDGIMMessageText *)msg).text;
        }else if ([msg isKindOfClass:[WDGIMMessageImage class]]){
            model.detailInfo = @"[ 图片 ]";
        }else if ([msg isKindOfClass:[WDGIMMessageVoice class]]){
            model.detailInfo = @"[ 语音 ]";
        }else if ([msg isKindOfClass:[WDGIMMessageGroupTip class]]){
            model.detailInfo = @"[ 群通知 ]";
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Delegate<UITableView>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recentChatList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDRESS_CELL_H;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* chatCellId = @"Chat";
    ConversationListCell* chatCell = [tableView dequeueReusableCellWithIdentifier:chatCellId];
    if (chatCell == nil) {
        chatCell = [[ConversationListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:chatCellId];
    }
    if (self.recentChatList.count > indexPath.row) {
        ConversationListModel* model = [self.recentChatList objectAtIndex:indexPath.row];
        [chatCell updateModel:model];
    }
    return chatCell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSLog(@"%s TableCell select: section:%ld index:%ld", __FILE__,  (long)indexPath.section, (long)indexPath.row);
    ConversationListModel *model = (ConversationListModel *)[self.recentChatList objectAtIndex:indexPath.row];
    ConversationViewController *chatCntler = [[ConversationViewController alloc]init];
    chatCntler.wildConversation = [self.wildClient getConversation:model.conversationId];
    chatCntler.groupName = [self.recentChatList[indexPath.row] title];
    chatCntler.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatCntler animated:YES];
}

- (NSDate *)getDateWithTimestamp:(NSString *)timestamp
{
    NSTimeInterval tempMilli = [timestamp longLongValue];
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

- (void)didReceiveMemoryWarning {
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
