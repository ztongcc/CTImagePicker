//
//  ImagePicker.h
//  BDKit
//
//  Created by admin on 16/1/19.
//  Copyright © 2016年 Evan.Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CTImagePickerFinishAction)(UIImage *image, BOOL isCancle);

@interface CTImagePicker : NSObject

/**
 @param viewController  用于present UIImagePickerController对象
 @param allowsEditing   是否允许用户编辑图像
 */
+ (void)showImagePickerFromViewController:(UIViewController *)viewController
                            allowsEditing:(BOOL)allowsEditing
                             finishAction:(CTImagePickerFinishAction)finishAction;

@end
