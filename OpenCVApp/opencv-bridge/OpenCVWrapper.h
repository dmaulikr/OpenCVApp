//
//  OpenCVWrapper.hpp
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/11/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *)processImageWithOpenCV:(UIImage*)inputImage;
-(void) createPatternDetector:(UIImage*)inputImage;
-(BOOL) isTracking;
-(float) matchValue;
-(CGPoint)matchPoint;
- (void)scanFrame:(unsigned char*)data width:(size_t)width height:(size_t)height stride:(size_t)stride;


@end
#endif
