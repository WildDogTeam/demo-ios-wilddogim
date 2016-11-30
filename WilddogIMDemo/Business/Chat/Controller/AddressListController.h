//
//  AddressListController.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseViewController.h"

@interface AddressListController : BaseViewController

@property (nonatomic, assign) BOOL fromOffline;
@property (nonatomic, copy) void(^ selectedUserBlock)(NSString *selectedUser);

@end
