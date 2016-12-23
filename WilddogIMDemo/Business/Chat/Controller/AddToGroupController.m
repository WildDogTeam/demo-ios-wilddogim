//
//  AddToGroupController.m
//  WilddogIM
//
//  Created by Garin on 16/7/4.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "AddToGroupController.h"
#import "AddToGroupModel.h"
#import "UserInfoDataBase.h"
#import "AddToGroupCell.h"
#import "GroupInfoDataBase.h"
#import "MsgTipsModel.h"
#import "GroupInfoModel.h"
#import "ConversationViewController.h"
#import <SVProgressHUD.h>

#import "WDGIM.h"

@interface AddToGroupController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end

@implementation AddToGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择联系人";
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49) style:UITableViewStylePlain];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self.navigationItem setLeftBarButtonItem:left];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeAction:)]];
    
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [shadow setShadowOffset:CGSizeMake(0, 1)];
    
    NSDictionary *attributesr = @{
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:220.0/255.0 green:104.0/255.0 blue:1.0/255.0 alpha:1.0],
                                 NSShadowAttributeName: shadow,
                                 NSFontAttributeName: [UIFont fontWithName:@"AmericanTypewriter" size:16.0]
                                 };
    NSDictionary *attributesl = @{
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:76/255.0 green:80/255.0 blue:80/255.0 alpha:1],
                                 NSShadowAttributeName: shadow,
                                 NSFontAttributeName: [UIFont fontWithName:@"AmericanTypewriter" size:16.0]
                                 };
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:attributesl forState: UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributesr forState: UIControlStateNormal];
    
    self.dataArray = [[NSMutableArray alloc]init];
    self.selectedArray = [[NSMutableArray alloc]init];
    
    NSArray *users = [[UserInfoDataBase sharedInstance]getMyAllFriends];
    for (UserInfoModel *info in users) {
        AddToGroupModel *model = [[AddToGroupModel alloc]initWithModel:info];
        [self.dataArray addObject:model];
    }
}
    
- (void)completeAction:(id)sender
{
    NSMutableArray *userArray = [NSMutableArray array];
    for (AddToGroupModel *user in self.dataArray) {
        if (user.selected) {
            [userArray addObject:user.userId];
        }
    }
    
    if (userArray.count==0) {
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在创建会话"];
    [[WDGIM im] newConversationWithMembers:userArray completion:^(WDGIMConversation * _Nullable conversation, NSError *__autoreleasing  _Nullable * _Nullable error) {
        [SVProgressHUD dismiss];
        if (!error) {
            ConversationViewController *vc = [[ConversationViewController alloc]init];
            vc.wildConversation = conversation;
            vc.hidesBottomBarWhenPushed = YES;
            [self.lastVC.navigationController pushViewController:vc animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"创建会话失败"];
        }
    }];
}

- (void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    AddToGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[AddToGroupCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setContent:[self.dataArray objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ADDRESS_CELL_H;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddToGroupCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    AddToGroupModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.selected == NO) {
        cell.btnImage.image = [UIImage imageNamed:@"ati.png"];
        model.selected = YES;
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
    }else{
        cell.btnImage.image = [UIImage imageNamed:@"atk.png"];
        model.selected = NO;
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
    }
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
