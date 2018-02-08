//
//  LZUserInfoViewController.m
//  ws_push_ios_1.0
//
//  Created by chengh on 16/11/11.
//  Copyright © 2016年 WNP. All rights reserved.
//
#import "MoreUserInfoViewController.h"
#import "CommonUtility.h"
#import "UserInfo.h"
#import "Constant.h"
#import "ServiceUtility.h"
#import "UIViewController+ForegroundGesture.h"
#import "TitleIconTableViewCell.h"
#import "UserInfoClearPictureViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Photos/Photos.h>
#import <UIButton+WebCache.h>

@interface LZUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImv;

@property (strong ,nonatomic) NSArray *infos;
@property (strong, nonatomic) UIImage *headImage;
@property (strong, nonatomic) UIImageView *headImv;
@property (strong, nonatomic) NSString *headImgUrl;

@end

@implementation LZUserInfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _infos = @[
               @{
                   @"title" : @"头像",
                   @"isImage" : @"YES"
                   },
               @{
                   @"title" : @"用户名",
                   @"content" : [UserInfo userChineseName] ? : @"暂无数据"
                   },
               @{
                   @"title" : @"邮箱",
                   @"content" : [UserInfo userEmail] ? : @"暂无数据"
                   },
               @{
                   @"title" : @"部门",
                   @"content" : [UserInfo userDepartment] ? : @"暂无数据"
                   }
               ];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
    [_tableView setSeparatorColor:Tableview_SeparatorColor];
    [_tableView registerNib:[UINib nibWithNibName:@"TitleIconTableViewCell" bundle:nil] forCellReuseIdentifier:@"moreImageCell"];
    _headImage = [CommonUtility userHeadImage];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentGestureVerifyViewController)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundImv.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    int contentHeight = _tableView.contentSize.height;
    if (contentHeight < _tableView.frame.size.height) {
        CGRect frame = self.tableView.frame;
        frame.size.height = contentHeight;
        _tableView.frame = frame;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - action

- (void)clickToSeeBigPicture{
    [self performSegueWithIdentifier:@"seeClearPictureSegue" sender:nil];
}


- (void)takePhoto{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [CommonUtility showAlert:@"您的设备不支持拍照功能" showController:self];
        return;
    }
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    [self presentViewController:pickerController animated:YES completion:nil];
}


- (void)pickPhoto{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        [CommonUtility showAlert:@"您的设备不支持该功能" showController:self];
        return;
    }
    //获取可以使用的类型，如图像，视频等。在这里判断是否支持图片，即UTCoreTypes类中的kUTTypeImage
    NSArray *availeType = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    if (![availeType containsObject:(NSString *)kUTTypeImage]) {
        [CommonUtility showAlert:@"您的设备不支持该功能" showController:self];
        return;
    }
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    [self presentViewController:pickerController animated:YES completion:nil];
}


- (void)synchronizeHeadImage:(UIImage *)image isJPGType:(BOOL)isJPG{
    [CommonUtility showProgressHud:@"" displayView:self.view];
    NSData *imageData;
    if (isJPG) {
        imageData = UIImageJPEGRepresentation(image,1.0);
    }else{
        imageData = UIImagePNGRepresentation(image);
    }
    if (!imageData) {
        NSLog(@"");
        return;
    }
    [CommonUtility saveHeadImage:imageData];
    [[ServiceUtility shareManger] uploadHeadImage:imageData isJPGType:isJPG successComplete:^{
        [CommonUtility hideHud:self.view];
        [CommonUtility showTextHud:@"" displayView:self.view hideDelayTime:2];
    } failComplete:^(NSString *reason) {
        [CommonUtility hideHud:self.view];
        [CommonUtility showAlert:reason showController:self];
    }];
}


- (NSString *)photoType:(NSURL *)url{
    PHFetchResult *results = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    if (results && results.count > 0) {
        NSArray *resources = [PHAssetResource assetResourcesForAsset:[results firstObject]];
        if (resources && resources.count > 0 ) {
            PHAssetResource *assetResource = [resources firstObject];
            NSString *type = assetResource.uniformTypeIdentifier;
            if (type && type.length > 0) {
                return type;
            }
        }
    }
    return nil;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if (info[UIImagePickerControllerEditedImage]) {
        _headImage = info[UIImagePickerControllerEditedImage];
        [_tableView reloadData];
        BOOL isJPG = YES;
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            if (info[UIImagePickerControllerReferenceURL]) {
                NSString *photoType = [self photoType:info[UIImagePickerControllerReferenceURL]];
                if ([(NSString *)kUTTypePNG isEqualToString:photoType]) {
                    isJPG = NO;
                }
            }else{
                NSLog(@"");
            }
        }
         [self synchronizeHeadImage:_headImage isJPGType:isJPG];
    }else{
        NSLog(@"");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _infos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item =  _infos[indexPath.row];
    if ([item[@"isImage"]boolValue]) {
        TitleIconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreImageCell" forIndexPath:indexPath];
        cell.headTitleLabel.text = item[@"title"];
        [cell.headImageButton setImage:_headImage forState:UIControlStateNormal];
        [cell.headImageButton addTarget:self action:@selector(clickToSeeBigPicture)  forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = item[@"title"];
        cell.detailTextLabel.text = item[@"content"];
        cell.userInteractionEnabled = NO;
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_infos[indexPath.row][@"isImage"]boolValue]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePic = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self takePhoto];
        }];
        UIAlertAction *choosePic = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pickPhoto];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:takePic];
        [alert addAction:choosePic];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_infos[indexPath.row][@"isImage"]boolValue]) {
        return 64;
    }else{
        return 44;
    }
}


@end
