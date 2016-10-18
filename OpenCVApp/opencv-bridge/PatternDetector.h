//
//  UIImage+OpenCV.hpp
//  OpenCVApp
//
//  Created by Vivek Nagar on 10/11/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

#include <opencv2/opencv.hpp>


struct VideoFrame
{
    size_t width;
    size_t height;
    size_t stride;
    
    unsigned char * data;
};

class PatternDetector
{
#pragma mark -
#pragma mark Public Interface
public:
    // (1) Constructor
    PatternDetector(const cv::Mat& pattern);
    
    // (2) Scan the input video frame
    void scanFrame(VideoFrame frame);
    
    // (3) Match APIs
    const cv::Point& matchPoint();
    float matchValue();
    float matchThresholdValue();
    
    // (4) Tracking API
    bool isTracking();
    
#pragma mark -
#pragma mark Private Members
private:
    // (5) Reference Marker Images
    cv::Mat m_patternImage;
    cv::Mat m_patternImageGray;
    cv::Mat m_patternImageGrayScaled;
    
    // (6) Supporting Members
    cv::Point m_matchPoint;
    int m_matchMethod;
    float m_matchValue;
    float m_matchThresholdValue;
    float m_scaleFactor;
};
