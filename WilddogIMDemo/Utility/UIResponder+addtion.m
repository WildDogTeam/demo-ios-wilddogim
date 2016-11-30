//
// Copyright 1999-2015 MyApp
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UIResponder+addtion.h"

@implementation UIResponder (addtion)


- (void)showAlert:(NSString*)title andMsg:(NSString*)msg{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)showPrompt:(NSString*)msg{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    alert.backgroundColor = RGBACOLOR(0xAA, 0xAA, 0xAA, 0.5);
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(dissmissPrompt:) userInfo:alert repeats:NO];
    [alert show];
}

- (void)dissmissPrompt:(NSTimer *)timer{
    UIAlertView* alert = (UIAlertView *)timer.userInfo;
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    alert = nil;
}

@end
