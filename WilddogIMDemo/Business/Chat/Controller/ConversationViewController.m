//
//  ConversationViewController.m
//  WilddogIM
//
//  Created by Garin on 16/6/28.
//  Copyright © 2016年 www.wilddog.com. All rights reserved.
//

#import "ConversationViewController.h"
#import "ImageViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "DTMessageInputToolBar.h"
#import "DTAudioManager.h"
#import "DTUtility.h"
#import "WDGDemoConstDefine.h"
#import "WildTimeFormat.h"
#import "UIImage+fixOrientation.h"
#import "MyMenuItem.h"

#import "ChatTimeModel.h"
#import "MsgTextModel.h"
#import "MsgTipsModel.h"
#import "MsgAudioModel.h"
#import "MsgPicModel.h"
#import "UserInfoModel.h"
#import "GroupInfoModel.h"
#import "UserInfoDataBase.h"

#import "ChatTipsCell.h"
#import "ChatTextCell.h"
#import "ChatTimeCell.h"
#import "ChatPicCell.h"
#import "ChatAudioCell.h"


#define MAX_CHATMSG_ORGIN_LOAD  50
#define TABLEVIEW_INPUTBAR_PADDING 10

static ConversationViewController *gCurrentConversationViewController;

@interface ConversationViewController ()<UITableViewDelegate, UITableViewDataSource,DTMesaageInputToolBarDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,ImageViewDelegate>
{
    NSTimeInterval _lastMsgTime;
    BOOL _isUpdateEnd;           //控制刷新频率
    BOOL _isFristUpdate;         //是否第一次刷新
    BOOL _bIsOriPic;
    
    WDGIMConversation *_conversation;
}
@property (nonatomic, retain) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;       //储存消息的队列
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) WDGIMMessage *lastMsg;            //上一次拉取的最后一条消息
@property (strong, nonatomic) DTMessageInputToolBar* toolbar;
@property (strong, nonatomic) ImageViewController *imageViewController;

@end

@implementation ConversationViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    gCurrentConversationViewController = self;
    
    self.tabBarController.tabBar.hidden = YES;
    _isFristUpdate = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    gCurrentConversationViewController = nil;
    [[DTAudioManager sharedInstance] stopPlay];
    
    [self setAllMsgReaded];
    
    if(self.dataSource.count == 0){
        [_conversation deleteConversation];
    }
    //退出聊天界面时，刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:kWildNotificationConversationListUpdate object:nil userInfo:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSubViews];
    [self setupRefresh];
    
    _lastMsg = nil;
    _isUpdateEnd = NO;
    _isFristUpdate = YES;
    
    NSString *title;

    if(self.wildConversation){
        _conversation = self.wildConversation;
        if ([_conversation.members count] == 2) {
            title = [[[UserInfoDataBase sharedInstance] getUserInfo:[Utility getOtherId:_conversation.conversationId]] name];
        }else{
            if (self.groupName.length == 0) {
                NSMutableArray *array = [NSMutableArray new];
                [_conversation.members enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    UserInfoModel *user = [[UserInfoDataBase sharedInstance] getUserInfo:obj];
                    [array addObject:CHECK_STR(user.name)];
                }];
                self.groupName = [array componentsJoinedByString:@","];
            }
            title = self.groupName;
        }
    }
    
    self.title = title;
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    
    [self updateData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appendRecieveMessage:) name:kWildNotificationConversationVCUpdate object:nil];
}

- (void)setupSubViews
{
    self.view.backgroundColor = [DTUtility colorWithHex:@"f7f7f8"];
    
    DTMessageInputToolBar *inputToolBar = [[DTMessageInputToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - DT_INPUTVIEW_HEIGHT , self.view.frame.size.width, self.view.frame.size.height)];
    inputToolBar.delegate = self;
    self.toolbar = inputToolBar;
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMinY(self.view.frame), CGRectGetWidth(self.view.frame), [UIScreen mainScreen].bounds.size.height - DT_INPUTVIEW_HEIGHT - TABLEVIEW_INPUTBAR_PADDING - 64);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionHeaderHeight = 10.f;
    _tableView.sectionFooterHeight = 0.f;
    _tableView.backgroundColor = [DTUtility colorWithHex:@"f7f7f8"];
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_toolbar];
    
    if (self.dataSource.count>=1) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped:)];
    self.tap = tap;
}



//添加刷新控件
-(void)setupRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

-(void)refreshStateChange:(UIRefreshControl *)control
{
    if (!_isUpdateEnd) {
        [self updateData];
    }
    [control endRefreshing];
}

- (void)updateData
{
    _isUpdateEnd = NO;
    NSArray *msgList = [_conversation getMessageFromLast:_lastMsg limit:MAX_CHATMSG_ORGIN_LOAD];
    if (msgList.count < 1) {
        if (!_isFristUpdate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }
        else {
            _isFristUpdate = NO;
        }
        _isUpdateEnd = YES;
        return ;
    }else{
        _isUpdateEnd = NO;
    }
    _lastMsg = msgList[msgList.count-1];
    NSArray *msgModels = [self removeDeletedMsg:msgList];
    
    NSIndexSet *indexSets = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, msgModels.count)];
    
    [self.dataSource insertObjects:msgModels atIndexes:indexSets];

    UITapGestureRecognizer* tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard)];
    [self.tableView addGestureRecognizer:tapAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.tableView.contentSize.height > self.tableView.frame.size.height)
        {
            static float offsetY = 0;
            //如果是第一次刷新，需要计算偏移量
            if (_isFristUpdate) {
                offsetY = self.tableView.contentSize.height - self.tableView.frame.size.height;
                _isFristUpdate = NO;
            }
            CGPoint offset = CGPointMake(0, offsetY);
            [self.tableView setContentOffset:offset animated:NO];
        }
        else{
            if (_isFristUpdate) {
                _isFristUpdate = NO;
            }
        }
    });
}

- (NSArray*)removeDeletedMsg:(NSArray*)msgList
{
    NSMutableArray *msgModel = [[NSMutableArray alloc] init];
    NSUInteger index = msgList.count;
    while (index>0) {
        WDGIMMessage * msg = [msgList objectAtIndex:index-1];
        if (msg.messageStatus == WDGIMMessageStatusDelete) {
            //被删除的消息不处理
        }
        else{
            //将消息转换为model
            [msgModel addObjectsFromArray:[self modelFromMessage:msg]];
        }
        index--;
    }

    return msgModel;
}

+ (ConversationViewController *)current
{
    return gCurrentConversationViewController;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[MsgTextModel class]]) {
        MsgTextModel* model = (MsgTextModel *)obj;
        return  [ChatTextCell heightForModel:model];
    }
    else if ([obj isKindOfClass:[ChatTimeModel class]]) {
        ChatTimeModel* model = (ChatTimeModel *)obj;
        return  [ChatTimeCell heightForModel:model];
    }else if ([obj isKindOfClass:[MsgTipsModel class]]) {
        MsgTipsModel* model = (MsgTipsModel *)obj;
        return  [ChatTipsCell heightForModel:model];
    }
    else if ([obj isKindOfClass:[MsgPicModel class]]) {
        MsgPicModel* model = (MsgPicModel *)obj;
        return  [ChatPicCell heightForModel:model];
    }
    else if ([obj isKindOfClass:[MsgAudioModel class]]) {
        MsgAudioModel* model = (MsgAudioModel *)obj;
        return  [ChatAudioCell heightForModel:model];
    }
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* kTextCellReusedID = @"TextCellReusedID";
    static NSString* kTimeCellReusedID = @"TimeCellReusedID";
    static NSString* kImageCellReusedID = @"ImageCellReusedID";
    static NSString* kAudioCellReusedID = @"AudioCellReusedID";
    static NSString* kTipsCellReusedID = @"TipsCellReusedID";
    
    UITableViewCell* cell;
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[MsgTextModel class]]) {
        ChatTextCell* textCell = [tableView dequeueReusableCellWithIdentifier:kTextCellReusedID];
        if (!textCell) {
            textCell = [[ChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextCellReusedID];
        }
        [textCell setContent:obj];
        cell = textCell;
    }
    else if ([obj isKindOfClass:[MsgPicModel class]]) {
        ChatPicCell* picCell = [tableView dequeueReusableCellWithIdentifier:kImageCellReusedID];
        if (!picCell) {
            picCell = [[ChatPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kImageCellReusedID];
        }
        [picCell setContent:obj];
        cell = picCell;
    }
    else if ([obj isKindOfClass:[MsgAudioModel class]]) {
        ChatAudioCell* audioCell = [tableView dequeueReusableCellWithIdentifier:kAudioCellReusedID];
        if (!audioCell) {
            audioCell = [[ChatAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAudioCellReusedID];
        }
        [audioCell setContent:obj];
        cell = audioCell;
    }
    else if ([obj isKindOfClass:[MsgTipsModel class]]) {
        ChatTipsCell* tipsCell = [tableView dequeueReusableCellWithIdentifier:kTipsCellReusedID];
        if (!tipsCell) {
            tipsCell = [[ChatTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTipsCellReusedID];
        }
        [tipsCell setContent:obj];
        cell = tipsCell;
    }
    else if ([obj isKindOfClass:[ChatTimeModel class]]) {
        ChatTimeCell* timeCell = [tableView dequeueReusableCellWithIdentifier:kTimeCellReusedID];
        if (!timeCell) {
            timeCell = [[ChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTimeCellReusedID];
        }
        [timeCell setContent:obj];
        cell = timeCell;
    }
    return cell;
}

#pragma mark DTMessageInputToolBarDelegate

- (void)didSendMessage:(NSString *)text
{
    if (text && text.length > 0) {
        MsgTextModel* model = [[MsgTextModel alloc ]init];
        model.inMsg = NO;
        model.textMsg = text;
        model.fromUserId = [Utility myUid];
        model.toUserId = [Utility getOtherId:_conversation.conversationId];
        model.conversationId = _conversation.conversationId;
        model.sendTime = [NSDate date];
        model.time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]*1000];
        [self sendTextMessage:model];
    }
}

- (void)didSendEmojiMessage:(NSString *)content
{
    [self didSendMessage:content];
}

- (void)didSendVoice:(DTAudioRecord *)audioRecord
{
    MsgAudioModel* audioModel = [[MsgAudioModel alloc] init];
    audioModel.data = audioRecord.audioData;
    audioModel.duration = audioRecord.duration;
    audioModel.isReaded = YES;
    audioModel.isPlayed = YES;
    audioModel.conversation = _conversation;
    audioModel.sendTime = [NSDate date];
    audioModel.time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]*1000];
    audioModel.inMsg = NO;
    audioModel.status = WDGIMMessageStatusSending;
    NSString *filePath = [self saveFileToLocalPath:audioRecord.audioData];
    audioModel.filePath = filePath;
    [self sendAudioMessage:audioModel];
}

- (void)pluginView:(DTPluginItem *)pluginView didSelectItemAtIndex:(NSInteger)index
{
    if ([pluginView.title isEqualToString:@"照片"]) {
        // 弹出照片选择
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
        
    }
    else if([pluginView.title isEqualToString:@"拍摄"]){
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self.imagePicker setEditing:YES];
        if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]){
            AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authorizationStatus == AVAuthorizationStatusRestricted
                || authorizationStatus == AVAuthorizationStatusDenied) {
                // 没有权限
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage* image = [info[UIImagePickerControllerOriginalImage] fixOrientation];
        self.imageViewController = [[[ImageViewController alloc] init] initViewController:image];
        [self.imageViewController setDelegate:self];
        [picker pushViewController:self.imageViewController animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self releaseImagePicker];
}

- (void)releaseImagePicker
{
    _imagePicker = nil;
}

#pragma mark- ImageViewControllerDelegate
- (void)sendImageAction:(UIImage*)image isSendOriPic:(BOOL)bIsOriPic{
    _bIsOriPic = bIsOriPic;
    [self willSendPcikerImage:image];
}

- (void)releasePicker{
    [self releaseImagePicker];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)willSendPcikerImage:(UIImage *)image
{
    MsgPicModel* model = [[MsgPicModel alloc] init];
    CGFloat scale = 1;
    scale = MIN(CELL_PIC_THUMB_MAX_H/image.size.height, CELL_PIC_THUMB_MAX_W/image.size.width);
    UIImage *thumbImage = [self thumbnailWithImage:image size:CGSizeMake(image.size.width*scale, image.size.height*scale)];
    model.data = UIImageJPEGRepresentation(thumbImage, 1);
    model.picHeight = image.size.height;
    model.picWidth = image.size.width;
    model.picThumbHeight = model.picHeight * scale;
    model.picThumbWidth = model.picWidth * scale;
    model.inMsg = NO;
    model.time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]*1000];
    model.status = WDGIMMessageStatusSending;
    
    NSString *filePath = [self saveFileToLocalPath:UIImageJPEGRepresentation(image, 0.75)];

    model.picPath = filePath;
    [self sendImageMessage:model];
}

- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

- (NSString *)saveFileToLocalPath:(NSData *)data
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [paths[0] stringByAppendingPathComponent:@"sendImage"];
    NSString *filePath = [NSString stringWithFormat:@"%@/uploadFile%3.f", diskCachePath, [NSDate timeIntervalSinceReferenceDate]];
    NSError *err;
    
    if (![fileManager fileExistsAtPath:diskCachePath]) {
        [fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }

    if (![fileManager createFileAtPath:filePath contents:data attributes:nil]) {
        NSLog(@"Upload Image Failed: fail to create uploadfile: %@", err);
        return nil;
    }
    
    return filePath;
}

- (void)inputToolBar:(DTMessageInputToolBar *)toolBar didChangeY:(float)y
{
    __weak ConversationViewController* weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = weakself.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = y;
        weakself.tableView.frame = rect;
    }];
    
    if (_tableView.contentSize.height >  _tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
        [_tableView setContentOffset:offset animated:YES];
    }
}

- (void)inputTextViewDidBeginEditing:(DTTextView *)textView
{
    [self.tableView addGestureRecognizer:self.tap];
}

- (void)inputTextViewDidEndEditing:(DTTextView *)textView
{
    [self.tableView removeGestureRecognizer:self.tap];
}

#pragma mark - Send message

-(void)sendTextMessage:(MsgTextModel*) model
{
    WDGIMMessage *message = [WDGIMMessage messageWithText:model.textMsg];
    
    [_conversation sendMessage:message completion:^(WDGIMMessage * _Nullable msg, NSError * _Nullable error) {
        model.msg = msg;
        model.status = msg.messageStatus;
        [self.tableView reloadData];
    }];
    
    [self appendSendMsg:model];
}

-(void)sendImageMessage:(MsgPicModel*)model
{
    if (!model.data) {
        return;
    }
    
    WDGIMMessageImage *imageMsg = [WDGIMMessage messageWithImagePath:model.picPath];
    
    [_conversation sendMessage:imageMsg completion:^(WDGIMMessage * _Nullable msg, NSError * _Nullable error) {
        model.msg = msg;
        model.status = msg.messageStatus;
        [self.tableView reloadData];
    }];
    
    model.msg = imageMsg;
    [self appendSendMsg:model];
}

-(void)sendAudioMessage:(MsgAudioModel*)model
{
    if (!model.data || model.duration < 1) {
        return;
    }
    
    WDGIMMessageVoice *audioMsg = [WDGIMMessage messageWithVoiceData:model.data duration:model.duration];
    
    audioMsg.filePath = model.filePath;
    [_conversation sendMessage:audioMsg completion:^(WDGIMMessage * _Nullable msg, NSError * _Nullable error) {
        model.msg = msg;
        model.status = msg.messageStatus;
        [self.tableView reloadData];
    }];
    
    model.msg = audioMsg;
    [self appendSendMsg:model];
}

- (void)appendSendMsg:(MsgBaseModel *) model
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    if ([model.sendTime timeIntervalSince1970] - _lastMsgTime > 60) {
        ChatTimeModel* timeModel = [[ChatTimeModel alloc] init];
        timeModel.inMsg = model.inMsg;
        timeModel.timeStr = [self formatMsgTime:model.sendTime];
        _lastMsgTime = [model.sendTime timeIntervalSince1970];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
        [indexPaths addObject:indexPath];
        [_dataSource addObject:timeModel];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count inSection:0];
    [indexPaths addObject:indexPath];
    [_dataSource addObject:model];
    
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (NSArray *)modelFromMessage:(WDGIMMessage *)msg
{
    NSMutableArray* models = [NSMutableArray arrayWithCapacity:2];
    BOOL isNeedTimeModel = NO;
    MsgBaseModel *baseModel = nil;
    ChatTimeModel* timeModel;
    if (fabs(msg.sentAt - _lastMsgTime) > 60*100) {
        timeModel = [[ChatTimeModel alloc] init];
        timeModel.timeStr = [self formatMsgTime:[self getDateWithTimestamp:[NSString stringWithFormat:@"%lld",msg.sentAt]]];
        timeModel.msg = msg;
        _lastMsgTime = msg.sentAt;
        isNeedTimeModel = YES;
    }
    if ([msg isKindOfClass:[WDGIMMessageText class]]) {
        MsgTextModel* textModel = [[MsgTextModel alloc]init];
        textModel.msg = msg;
        textModel.textMsg = ((WDGIMMessageText *)msg).text;
        baseModel = textModel;
    }else if([msg isKindOfClass:[WDGIMMessageImage class]]) {
        MsgPicModel* picModel = [[MsgPicModel alloc]init];
        WDGIMMessageImage *imageMsg = (WDGIMMessageImage *)msg;
        picModel.msg = msg;
        picModel.picWidth = imageMsg.width;
        picModel.picHeight = imageMsg.height;
        baseModel = picModel;
    }else if ([msg isKindOfClass:[WDGIMMessageVoice class]]){
        MsgAudioModel *audioModel = [[MsgAudioModel alloc] init];
        audioModel.msg = msg;
        baseModel = audioModel;
    }else if([msg isKindOfClass:[WDGIMMessageGroupTip class]]){
        WDGIMMessageGroupTip *groupMsg = (WDGIMMessageGroupTip *)msg;
        isNeedTimeModel = NO;
        NSArray* tipsArray = [self formatGroupTipsMsg:groupMsg];
        MsgTipsModel* tipsModel;
        for (NSString* tip in tipsArray) {
            tipsModel = [[MsgTipsModel alloc] init];
            tipsModel.tipsStr = tip;
        }
        baseModel = tipsModel;
    }
    baseModel.status = msg.messageStatus;
    baseModel.sendTime = [NSDate dateWithTimeIntervalSince1970:msg.sentAt];
    
    if([msg.sender isEqualToString:[Utility myUid]]){
        baseModel.inMsg = NO;
    }else{
        baseModel.inMsg = YES;
    }
    [models addObject:baseModel];
    
    if (isNeedTimeModel) {
        [models insertObject:timeModel atIndex:0];
    }
    
    return models;
}

- (NSString *)formatMsgTime:(NSDate *)date
{
    NSString* strDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    strDate = [dateFormatter stringFromDate:date];
    
    return strDate;
}

- (NSArray *)formatGroupTipsMsg:(WDGIMMessageGroupTip *)msg
{
    NSMutableArray* tipsArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableString* userList = [[NSMutableString alloc] init];
    int i = 0;
    NSString* action;
    switch (msg.groupTipType) {
        case WDIMGroupTipsTypeJoin:
        {
            action = @"%@ 邀请 %@ 加入了群";
            i = 0;
            NSMutableArray *newOperatedUsers = [NSMutableArray arrayWithArray:msg.operatedUsers];
            [newOperatedUsers removeObject:msg.operateUser];
            for (NSString* user in newOperatedUsers) {
                if (i++ > 0) {
                    [userList appendString:@","];
                }
                [userList appendString:[[UserInfoDataBase sharedInstance] getUserInfo:user].name];
            }
            [tipsArray addObject:[NSString stringWithFormat:action, [[UserInfoDataBase sharedInstance] getUserInfo:msg.operateUser].name, userList]];
            break;
        }
        case WDGIMGroupTipsTypeQuit:
            action = @"%@ 退出了群";
            [tipsArray addObject:[NSString stringWithFormat:action,  [[UserInfoDataBase sharedInstance] getUserInfo:msg.operateUser].name]];
            break;
        case WDGIMGroupTipsTypeRemove:
            action = @"%@ 将 %@ 移除出群";
            userList = [[NSMutableString alloc] init];
            i = 0;
            for (NSString* user in msg.operatedUsers) {
                if (i++ > 0) {
                    [userList appendString:@","];
                }
                [userList appendString:[[UserInfoDataBase sharedInstance] getUserInfo:user].name];
            }
            [tipsArray addObject:[NSString stringWithFormat:action, [[UserInfoDataBase sharedInstance] getUserInfo:msg.operateUser].name, userList]];
            break;
        default:
            break;
    }
    return tipsArray;
}

//add a cell
-(void)appendRecieveMessage:(NSNotification *)notify
{
    NSArray *messages = [notify.userInfo objectForKey:@"msgs"];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (WDGIMMessage *message in messages) {
        
        WDGIMConversation *conversation = message.conversation;
        if (![conversation.conversationId isEqualToString:_conversation.conversationId]) {
            continue;
        }
        
        NSArray *msgModels = [NSArray arrayWithArray:[self modelFromMessage:message]];
        
        for (int i = 0; i < msgModels.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count+i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [_dataSource addObjectsFromArray:msgModels];
    }

    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)setAllMsgReaded
{
    if (_conversation.totalNumberOfUnreadMessages > 0 ) {
        //当前视图可见，则标记为已读
        if (!self.view.hidden) {
            [_conversation markAllMessagesAsRead:nil];
            //更新RecentView
            [[NSNotificationCenter defaultCenter] postNotificationName:kWildNotificationConversationListUpdate object:nil];
        }
    }
}

- (NSDate *)getDateWithTimestamp:(NSString *)timestamp
{
    NSTimeInterval tempMilli = [timestamp longLongValue];
    NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

-(void)hiddenKeyBoard
{
    [_toolbar endEditing:YES];
}

- (void)tableViewTapped:(id)sender
{
    [self.toolbar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        if([self.toolbar.inputView.textView isFirstResponder])
        [self.toolbar resignFirstResponder];
    }
}

#pragma mark - Cell Tap


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
    if (action == @selector(deleteCell:) ) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id model = [self.dataSource objectAtIndex:indexPath.row];
    MsgBaseModel *baseModel = (MsgBaseModel *)model;
    
    __weak ConversationViewController *weakSelf = self;
    __block NSIndexPath *index = indexPath;
    
    if ([cell isKindOfClass:[MsgBaseCell class]])
    {
        MsgBaseCell *chatCell = (MsgBaseCell *)cell;
        
        UIView *view = [chatCell showMenuView];
        if (view)
        {
            [self canBecomeFirstResponder];
            [cell becomeFirstResponder];
            NSMutableArray *arrayItems = [[NSMutableArray alloc] init];
            
            MyMenuItem *delete = [[MyMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteCell:)];
            delete.tag = ChatViewMenu_ItemDelete;
            delete.menuAction = ^(MyMenuItem *item) {
                [weakSelf OnDeleteCellAt:index];
            };
            [arrayItems addObject:delete];
            
            if (baseModel.status == WDGIMMessageStatusFailed && ![baseModel isKindOfClass:[MsgAudioModel class]]) {
                MyMenuItem *resend = [[MyMenuItem alloc] initWithTitle:@"重发" action:@selector(resendCell:)];
                resend.tag = ChatViewMenu_ItemResend;
                resend.menuAction = ^(MyMenuItem *item){
                    [weakSelf OnResendCell:index];
                };
                [arrayItems addObject:resend];
            }
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:arrayItems];
            [menu setTargetRect:view.bounds inView:view];
            [menu setMenuVisible:YES animated:YES];
            return YES;
        }
    }
    return NO;
}

- (void)resendCell:(UIMenuController *)sender{
    for (MyMenuItem *item in sender.menuItems) {
        if ((item.tag == ChatViewMenu_ItemResend) && item.menuAction) {
            item.menuAction(item);
        }
    }
}

- (void)OnResendCell:(NSIndexPath *)index{
    id model = [self.dataSource objectAtIndex:index.row];
    [self OnDeleteCellAt:index];
    
    ((MsgBaseModel *)model).sendTime = [NSDate date];
    
    if ([model isKindOfClass:[MsgTextModel class]]) {
        [self sendTextMessage:model];
    }
    else if ([model isKindOfClass:[MsgAudioModel class]]) {
        [self sendAudioMessage:model];
    }
    else if ([model isKindOfClass:[MsgPicModel class]]) {
        [self sendImageMessage:model];
        [self appendSendMsg:model];
    }
}

- (void)deleteCell:(UIMenuController *)sender{
    NSLog(@"deleteCell");
    
    for (MyMenuItem *item in sender.menuItems) {
        if ((item.tag == ChatViewMenu_ItemDelete) && item.menuAction) {
            item.menuAction(item);
        }
    }
}

- (void)OnDeleteCellAt:(NSIndexPath *)index
{
    NSInteger indexRow = [index row];
    
    NSIndexPath *preIndex = nil;
    UITableViewCell *preCell = nil;
    
    NSIndexPath *nextIndex = nil;
    UITableViewCell *nextCell = nil;
    
    if (indexRow > 0) {
        preIndex = [NSIndexPath indexPathForRow:indexRow-1 inSection:0];
        preCell = [self.tableView cellForRowAtIndexPath:preIndex];
    }
    if (indexRow < self.dataSource.count-1) {
        nextIndex = [NSIndexPath indexPathForRow:indexRow+1 inSection:0];
        nextCell = [self.tableView cellForRowAtIndexPath:nextIndex];
    }
    
    NSArray *deleteArray = nil;
    
    //case1：当前cell的上一个cell为timecell且后一个cell也为timecell
    //case2:当前cell的上一个cell为timecell且后一个cell为空
    //以上两种情况，需要删除cell前面的timecell;
    if (preCell) {
        id preObj = nil;
        if (nextCell) {
            preObj = [self.dataSource objectAtIndex:preIndex.row];
            id nextObj = [self.dataSource objectAtIndex:nextIndex.row];
            
            if ([preObj isKindOfClass:[ChatTimeModel class]] && [nextObj isKindOfClass:[ChatTimeModel class]]){
                deleteArray = [[NSArray alloc] initWithObjects:index,preIndex, nil];
            }
            else{
                deleteArray = [[NSArray alloc] initWithObjects:index, nil];
            }
        }
        else{
            preObj = [self.dataSource objectAtIndex:preIndex.row];
            if ([preObj isKindOfClass:[ChatTimeModel class]]) {
                deleteArray = [[NSArray alloc] initWithObjects:index,preIndex, nil];
            }
            else{
                deleteArray = [[NSArray alloc] initWithObjects:index, nil];
            }
        }
    }
    
    [_tableView beginUpdates];
    
    [_tableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationRight];//@[index, preIndex]
    
    for (int i=0; i<deleteArray.count; i++) {
        NSIndexPath *tempIndex = [deleteArray objectAtIndex:i];
        id obj = [_dataSource objectAtIndex:tempIndex.row];
        if (![obj isKindOfClass:[ChatTimeModel class]]) {
            MsgBaseModel *baseModel = obj;
            [baseModel.msg deleteMessage];
        }
        [_dataSource removeObjectAtIndex:tempIndex.row];
    }
    
    [_tableView endUpdates];
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
