//
//  UIImage+OpenCV.hpp
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/11/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface UIImage (OpenCV)

//cv::Mat to UIImage
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
- (id)initWithCVMat:(const cv::Mat&)cvMat;

//UIImage to cv::Mat
- (cv::Mat)CVMat;
- (cv::Mat)CVMat3;  // no alpha channel
- (cv::Mat)CVGrayscaleMat;

@end
#endif

