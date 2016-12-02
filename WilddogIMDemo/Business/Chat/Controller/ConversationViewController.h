//
//  ConversationViewController.h
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "BaseViewController.h"
#import <WilddogIM/WilddogIM.h>

@interface ConversationViewController : BaseViewController

@property (nonatomic, retain) WDGIMConversation *wildConversation;

@property (nonatomic, retain) NSString *groupName;

+ (ConversationViewController *)current;

-(void)hiddenKeyBoard;

@end
