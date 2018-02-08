//
//  CustomerFeedBackViewController.m
//  ws_push_ios_1.0
//
//  Created by chengh on 2017/10/16.
//  Copyright © 2017年 huangm. All rights reserved.
//

#import "CustomerFeedbackViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Masonry/Masonry.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CustomFeedbackShowEditImageCell.h"
#import "TZImagePickerController.h"
#import "ServiceUtility.h"
#import "CommonUtility.h"

#define MAX_CHARA_ALLOWED   @"输入限制XXX字符"
#define ITEM_TITLE          @"xxxxxx"
#define ITEM_ADVICE         @"xxxxxx"
#define ITEM_TITLE          @"xxxxxx"



@interface CustomerFeedbackViewController()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) TZImagePickerController *tzimagePickerVc;

@property (nonatomic,strong) UIView *suggestView;
@property (nonatomic,strong) UITextView *feedBackTextView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIButton *commitBtn;

@property (nonatomic,strong) UILabel *conntactTitle;
@property (nonatomic,strong) UITextView *conntactDetail;
@property (nonatomic,strong) NSString *feedbackString;
@property (nonatomic,strong) NSMutableArray *feebackImages;

@property (nonatomic,strong) NSMutableArray *selectedPhotos;
@property (nonatomic,strong) NSMutableArray *selectedAssets;
@property (nonatomic,assign) CGFloat itemWH;
@property (nonatomic,assign) CGFloat margin;
@property (nonatomic,assign) BOOL isSelectOriginalPhoto;

@end

@implementation CustomerFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    self.title = ITEM_TITLE;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = WSColor(236, 240, 236, 1.0);
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


#pragma mark - pravite methond

- (BOOL)prefersStatusBarHidden {
    return NO;
}


- (void)commitPic{
    if (_selectedPhotos.count == 0 && self.feedbackString == nil) {
        return;
    }else{
        [[ServiceUtility shareManger] uploadFeedbackImageArr:_selectedPhotos feedbackText:self.feedbackString successComplete:^{
            [CommonUtility hideHud:self.view];
            [CommonUtility showTextHud:@"上传反馈成功" displayView:self.view hideDelayTime:2.0f];
        } failComplete:^(NSString *reason) {
            [CommonUtility hideHud:self.view];
            if ([reason isEqualToString:@"token信息不合法"]) {
                [CommonUtility showAlert:JudegeTokenISLegalFromMsg showController:self];
            }
            [CommonUtility showAlert:reason showController:self];
        }];
    }
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger num = _selectedPhotos.count;
    NSUInteger count = num < 3 ? num+ 1: num;
    return count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomFeedbackShowEditImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CustomFeedbackShowEditImageCell idtentify] forIndexPath:indexPath];
    cell.delegate = self;
    if (_selectedPhotos.count >= 3) {
        cell.deleButton.enabled = YES;
        cell.deleButton.hidden = NO;
        cell.imgv.image = _selectedPhotos[indexPath.row];
    }else {
        if (indexPath.row == _selectedPhotos.count) {//最后一张 添加图片
            cell.imgv.image = [UIImage imageNamed:@"addPic"];
            cell.deleButton.enabled = NO;
            cell.deleButton.hidden = YES;
        }else {
            cell.deleButton.enabled = YES;
            cell.deleButton.hidden = NO;
            cell.imgv.image = _selectedPhotos[indexPath.row];
        }
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomFeedbackShowEditImageCell *cell = (CustomFeedbackShowEditImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.deleButton.hidden) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"去相册选择", nil];
        [sheet showInView:self.view];
    }else {
        TZImagePickerController * tzimagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
        tzimagePickerVc.maxImagesCount = 3;
        tzimagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
        [  tzimagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            _selectedPhotos = [NSMutableArray arrayWithArray:photos];
            _selectedAssets = [NSMutableArray arrayWithArray:assets];
            _isSelectOriginalPhoto = isSelectOriginalPhoto;
            [collectionView reloadData];
            collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
        }];
        [self presentViewController: tzimagePickerVc animated:YES completion:nil];
    }
}


#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:3  columnNumber:3
     //个性化设置，这些参数都可以不传，此时会走默认设置
    if (_selectedPhotos.count > 0) {
        imagePickerVc.selectedAssets = _selectedAssets;
    }
    imagePickerVc.allowTakePicture = NO;
    [imagePickerVc.navigationBar setTintColor:WSColor(245, 245, 245, 1.0f)];
    imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.maxImagesCount = 3;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


#pragma mark - UIImagePickerController

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0 ){
        [self pushTZImagePickerController];
    }else{
        [actionSheet removeFromSuperview];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 前往设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.markedTextRange == nil && textView.text.length > 200) {
        [CommonUtility showTextHud:MAX_CHARA_ALLOWED displayView:self.view hideDelayTime:2.0f];
        //截取
        textView.text = [textView.text substringToIndex:200];
    }
    self.feedbackString = textView.text;
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    if(textView.text.length < 1){
        textView.text = ITEM_ADVICE;
        textView.textColor = [UIColor grayColor];
        self.commitBtn.backgroundColor = WSColor(165, 202, 242, 1.0f);
    }
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:ITEM_ADVICE]){
        textView.text = @"";
        textView.textColor=[UIColor blackColor];
        self.commitBtn.backgroundColor = WSColor(64, 105, 217, 1.0f);
    }
}


#pragma mark - hide keyboard

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)tap:(UITapGestureRecognizer*)tap{
    [self.feedBackTextView resignFirstResponder];
}


#pragma mark - TZImagePickerControllerDelegate

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
}


- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];

}


- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    return YES;
}


#pragma mark - CustomFeedbackShowEditImageCellDelegate

- (void)deleAction:(CustomFeedbackShowEditImageCell *)cell {
    NSInteger index = [self.collectionView indexPathForCell:cell].item;
    if (index < _selectedPhotos.count) {
        [_selectedPhotos removeObjectAtIndex:index];
        [_selectedAssets removeObjectAtIndex:index];
        [self.collectionView reloadData];
    }
}


#pragma mark - UI

- (void)configUI{
    [self.view addSubview:self.suggestView];
    [self.suggestView addSubview:self.feedBackTextView];
    [self.suggestView addSubview:self.collectionView];
    [self.view addSubview:self.conntactTitle];
    [self.view addSubview:self.conntactDetail];
    [self.view addSubview:self.commitBtn];
    //增加手势移除键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    CGFloat topHeight = (kScreenHeight-64 )/2;
    CGFloat chooseEditImgH = topHeight/3;
    CGFloat textViewH = topHeight - chooseEditImgH;
    __weak typeof(self) weakSelf = self;
    
    [self.suggestView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(64+20);
        make.bottom.mas_equalTo(weakSelf.view.mas_top).mas_offset(topHeight+64+20);
        make.left.mas_equalTo(weakSelf.view.mas_left);
        make.right.mas_equalTo(weakSelf.view.mas_right);
    }];
    
    [self.feedBackTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.suggestView.mas_top);
        make.bottom.mas_equalTo(weakSelf.suggestView.mas_top).mas_offset(textViewH);
        make.left.mas_equalTo(weakSelf.suggestView.mas_left);
        make.right.mas_equalTo(weakSelf.suggestView.mas_right);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.feedBackTextView.mas_bottom);
        make.bottom.mas_equalTo(weakSelf.suggestView.mas_bottom);
        make.left.mas_equalTo(weakSelf.suggestView.mas_left).offset(10);
        make.right.mas_equalTo(weakSelf.suggestView.mas_right).offset(-10);
    }];
    
    [self.conntactTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.suggestView.mas_bottom).offset(20);
        make.height.mas_offset(44);
        make.left.mas_equalTo(weakSelf.view.mas_left);
        make.right.mas_equalTo(weakSelf.view.mas_right);
    }];
    
    [self.conntactDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.conntactTitle.mas_bottom).offset(1);
        make.height.mas_offset(kScreenHeight/4-64);
        make.left.mas_equalTo(weakSelf.view.mas_left);
        make.right.mas_equalTo(weakSelf.view.mas_right);
    }];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_bottom).offset(-44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom);
        make.left.mas_equalTo(weakSelf.view.mas_left);
        make.right.mas_equalTo(weakSelf.view.mas_right);
    }];
}


#pragma mark - getter & setter

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
        BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}


- (UIView *)suggestView{
    if (!_suggestView ) {
        _suggestView = [[UIView alloc] init];
        _suggestView.backgroundColor = [UIColor whiteColor];
    }
    return _suggestView;
}


- (UITextView *)feedBackTextView {
    if (!_feedBackTextView) {
        _feedBackTextView = [[UITextView alloc] init];
        _feedBackTextView.text = ITEM_ADVICE;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 8;
        NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:18.0f], NSParagraphStyleAttributeName:paragraphStyle};
        _feedBackTextView.attributedText = [[NSAttributedString alloc]initWithString: _feedBackTextView.text attributes:attributes];
        _feedBackTextView.textColor = [UIColor grayColor];
        _feedBackTextView.delegate = self;
    }
    return _feedBackTextView;
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 5;
        layout.itemSize = CGSizeMake(105, 90);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 10,kScreenWidth - 2 * 15, 280) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[CustomFeedbackShowEditImageCell class] forCellWithReuseIdentifier:[CustomFeedbackShowEditImageCell idtentify]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}


- (UILabel *)conntactTitle{
    if (!_conntactTitle) {
        _conntactTitle = [[UILabel alloc] init];
        _conntactTitle.text = @"联系我们";
        _conntactTitle.font = [UIFont systemFontOfSize: 20];
        _conntactTitle.textAlignment = NSTextAlignmentLeft;
        _conntactTitle.backgroundColor = [UIColor whiteColor];
    }
    return _conntactTitle;
}


- (UITextView *)conntactDetail {
    if (!_conntactDetail ) {
        _conntactDetail = [[UITextView alloc] init];
        _conntactDetail.text = ITEM_ADVICE;
        [_conntactDetail setEditable:NO];
        _conntactDetail.textColor = [UIColor lightGrayColor];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:paragraphStyle};
        _conntactDetail.attributedText = [[NSAttributedString alloc]initWithString: _conntactDetail.text attributes:attributes];
    }
    return _conntactDetail;
}


- (UIButton *)commitBtn{
    if (!_commitBtn) {
        _commitBtn = [[UIButton alloc] init];
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        _commitBtn.backgroundColor = WSColor(165, 202, 242, 1.0f);
        [_commitBtn addTarget:self action:@selector(commitPic) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitBtn;
}


@end

