//
//  ImagePicker.m
//  BDKit
//
//  Created by admin on 16/1/19.
//  Copyright © 2016年 Evan.Cheng. All rights reserved.
//

#import "CTImagePicker.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define _SYSTEM_VERSION_   [[[UIDevice currentDevice] systemVersion] floatValue]
#define _IOS_OVER(__VERSION__)      (_SYSTEM_VERSION_ >= __VERSION__)


@interface CTImagePicker()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, copy) CTImagePickerFinishAction finishAction;
@property (nonatomic, assign) BOOL allowsEditing;

@end


static CTImagePicker * imagePickerInstance = nil;

@implementation CTImagePicker

+ (void)showImagePickerFromViewController:(UIViewController *)viewController allowsEditing:(BOOL)allowsEditing finishAction:(CTImagePickerFinishAction)finishAction
{
    if (imagePickerInstance == nil) {
        imagePickerInstance = [[CTImagePicker alloc] init];
    }
    
    [imagePickerInstance showImagePickerFromViewController:viewController
                                               allowsEditing:allowsEditing
                                                finishAction:finishAction];
}

- (void)showImagePickerFromViewController:(UIViewController *)viewController
                            allowsEditing:(BOOL)allowsEditing
                             finishAction:(CTImagePickerFinishAction)finishAction
{
    _viewController = viewController;
    _finishAction = finishAction;
    _allowsEditing = allowsEditing;
    
    [self showActionSheet];
}

- (void)showActionSheet
{
    if (_IOS_OVER(8.0)) {
        UIAlertController * controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [controller addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showImagePickerControllerWithActionTitle:@"拍照"];
            }]];
        }
        [controller addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showImagePickerControllerWithActionTitle:@"从相册选择"];
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        [_viewController presentViewController:controller animated:YES completion:nil];
    }else {
        UIActionSheet * sheet = nil;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
        }else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
        }
        UIView *window = [UIApplication sharedApplication].keyWindow;
        [sheet showInView:window];
    }
}

- (BOOL)isAuthorizationStatusWithIndex:(NSInteger)index
{
    if (index == 0) {
        if(_IOS_OVER(7.0))
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
            {
                //无权限
                if (_IOS_OVER(8.0)) {
                    UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"你无权访问相机:请到手机设置->隐私->相机中授权" preferredStyle:UIAlertControllerStyleAlert];
                    [controller  addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [controller dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    [controller addAction:[UIAlertAction actionWithTitle:@"现在就去" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        [controller dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    [_viewController presentViewController:controller animated:YES completion:nil];
                }else {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你无权访问相机:请到手机设置->隐私->相机中授权" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                }
                return NO;
            }
        }
        return YES;
    }else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            if (_IOS_OVER(8.0)) {
                UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"你无权访问相册:请到手机设置->隐私->照片中授权" preferredStyle:UIAlertControllerStyleAlert];
                [controller  addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [controller dismissViewControllerAnimated:YES completion:nil];
                }]];
                [controller addAction:[UIAlertAction actionWithTitle:@"现在就去" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    [controller dismissViewControllerAnimated:YES completion:nil];
                }]];
                [_viewController presentViewController:controller animated:YES completion:nil];
            }else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你无权访问相册:请到手机设置->隐私->照片中授权" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
            return NO;
        }else {
            return YES;
        }
    }
}

- (void)showImagePickerControllerWithActionTitle:(NSString *)title
{
    if ([title isEqualToString:@"拍照"]) {
        if (![self isAuthorizationStatusWithIndex:0]) return;
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = _allowsEditing;
        if(_IOS_OVER(8.0)) {
            picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [_viewController presentViewController:picker animated:YES completion:nil];
       
    }else if ([title isEqualToString:@"从相册选择"]) {
        if (![self isAuthorizationStatusWithIndex:1]) return;

        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = _allowsEditing;
        [_viewController presentViewController:picker animated:YES completion:nil];
    }else {
        imagePickerInstance = nil;
    }
}

#pragma mark - actionSheet delegate -
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    [self showImagePickerControllerWithActionTitle:title];
}

#pragma mark - navigationController delegate -
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:NSClassFromString(@"PUUIImageViewController")]) {
        viewController.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - UIImagePickerController delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    if (_finishAction) {
        _finishAction(image, NO);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    imagePickerInstance = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_finishAction) {
        _finishAction(nil, YES);
    }

    [picker dismissViewControllerAnimated:YES completion:nil];

    imagePickerInstance = nil;
}

-(void)dealloc
{
    NSLog(@"-------");
}
@end
