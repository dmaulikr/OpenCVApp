//
//  OpenCVWrapper.cpp
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/11/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

#ifdef __OBJC__
#import "OpenCVWrapper.h"
#import "UIImage+OpenCV.h"
#import "PatternDetector.h"

#import <opencv2/opencv.hpp>

using namespace cv;
using namespace std;


@implementation OpenCVWrapper : NSObject
PatternDetector *detector;


+ (UIImage *)processImageWithOpenCV:(UIImage*)inputImage {
    Mat mat = [inputImage CVMat];
    
    // do your processing here
    //...
    
    return [UIImage imageWithCVMat:mat];
}

-(void) createPatternDetector:(UIImage*)inputImage {
    Mat mat = [inputImage CVMat];
    detector = new PatternDetector(mat);
}

-(BOOL) isTracking {
    return detector->isTracking();
}

-(float) matchValue {
    return detector->matchValue();
}

-(CGPoint) matchPoint {
    cv::Point2f matchPoint = detector->matchPoint();
    return CGPointMake(matchPoint.x, matchPoint.y);
}

- (void)scanFrame:(unsigned char*)data width:(size_t)width height:(size_t)height stride:(size_t)stride {
    VideoFrame frame;
    frame.data = data;
    frame.width = width;
    frame.height = height;
    frame.stride = stride;
    
    return detector->scanFrame(frame);
}

@end
#endif
