//
//  AddressListController.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "AddressListController.h"
#import "ConversationViewController.h"
#import "MyUIDefine.h"
#import "UIImageView+WebCache.h"
#import "UserInfoModel.h"
#import "UserInfoDataBase.h"
#import "AuthenticationService.h"
#import <SVProgressHUD.h>
#import <WilddogIM/WilddogIM.h>

@interface AddressListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* friendList;
@end

@implementation AddressListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friendList = [NSMutableArray arrayWithCapacity:50];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:view];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    
    if (self.fromOffline == NO) {
        self.title = @"通讯录";

        self.friendList = [NSMutableArray arrayWithArray:[[UserInfoDataBase sharedInstance] getMyAllFriends]];
        [self.tableView reloadData];

    }else{
        self.title = @"请选择登录用户";

        [SVProgressHUD showWithStatus:@"正在获取登录用户"];
        [[AuthenticationService sharedInstance] getOfflineUserWithCompletion:^(NSError *error, id result) {
            [SVProgressHUD dismiss];
            if(!error){
                NSMutableArray *array = [NSMutableArray new];
                [array addObjectsFromArray:result[@"offLineUids"]];
                [self.friendList addObjectsFromArray:[array sortedArrayUsingComparator:cmptr]];
                [self.tableView reloadData];
            }else{
                [SVProgressHUD showErrorWithStatus:@"获取用户失败"];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

NSComparator cmptr = ^(id obj1, id obj2)
{
    if ([obj1 integerValue] > [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 integerValue] < [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

#pragma mark - Delegate<UITableView>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDRESS_CELL_H;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    if (self.fromOffline == NO) {
        cell.textLabel.text = [[self.friendList objectAtIndex:indexPath.row]name];
        
        //SDWebImage下载图片
        NSURL *url = [NSURL URLWithString:[[self.friendList objectAtIndex:indexPath.row]avatar]];
        [cell.imageView setFrame:CGRectMake(10, 10, 30, 30)];
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Icon"]];
        [cell.imageView.layer setCornerRadius:cell.imageView.frame.size.height/2 ];
        [cell.imageView.layer setMasksToBounds:YES];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"野狗%@号",self.friendList[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.fromOffline == NO) {
        ConversationViewController *vc = [[ConversationViewController alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        UserInfoModel *passModel = [self.friendList objectAtIndex:indexPath.row];
        
        WDGIM *client = [WDGIM im];
        if (passModel) {
            [client newConversationWithMembers:@[passModel.userId] completion:^(WDGIMConversation * _Nullable conversation, NSError *__autoreleasing  _Nullable * _Nullable error) {
                vc.wildConversation = conversation;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
    }else{
        if (self.selectedUserBlock) {
            self.selectedUserBlock([NSString stringWithFormat:@"%@",self.friendList[indexPath.row]]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
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
