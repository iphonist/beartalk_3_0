//
//  GKImagePicker.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImagePicker.h"
#import "GKImageCropViewController.h"

@interface GKImagePicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, GKImageCropControllerDelegate>
@property (nonatomic, strong, readwrite) UIImagePickerController *imagePickerController;
- (void)_hideController;
@end

@implementation GKImagePicker

#pragma mark -
#pragma mark Getter/Setter

@synthesize cropSize, delegate, resizeableCropArea, sourceType;
@synthesize imagePickerController = _imagePickerController;


#pragma mark -
#pragma mark Init Methods

- (id)init{
    if (self = [super init]) {
        NSLog(@"init");
        self.cropSize = CGSizeMake(320, 320);
        NSLog(@"self.cropSize %@",NSStringFromCGSize(self.cropSize));
        self.resizeableCropArea = YES;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        
        //		_imagePickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return self;
}

- (void)setSourceType:(UIImagePickerControllerSourceType)type{
    _imagePickerController.sourceType = type;
    NSLog(@"self.sourceType UIImagePickerControllerSourceTypeCamera %@",_imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera?@"YES":@"NO");
}

# pragma mark -
# pragma mark Private Methods

- (void)_hideController{
    
    if (![_imagePickerController.presentedViewController isKindOfClass:[UIPopoverController class]]){
        
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}

#pragma mark -
#pragma mark UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        
        [self.delegate imagePickerDidCancel:self];
        
    } else {
        
        [self _hideController];
        
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSLog(@"didFinishPickingMediaWithInfo");
    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
//    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
//    cropController.popoverContentSize = SharedAppDelegate.window.frame.size;
    cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    cropController.resizeableCropArea = self.resizeableCropArea;
    cropController.cropSize = self.cropSize;
    NSLog(@"self.cropSize %@",NSStringFromCGSize(self.cropSize));
    cropController.delegate = self;
    
 
    dispatch_async(dispatch_get_main_queue(), ^{
//    if(![picker.topViewController isKindOfClass:[cropController class]])
        
        [picker pushViewController:cropController animated:YES];
    });
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    NSLog(@"didFinishWithCroppedImage");
    if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
        [self.delegate imagePicker:self pickedImage:croppedImage];
    }
}

@end
