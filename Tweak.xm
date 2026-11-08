#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <VideoToolbox/VideoToolbox.h>

// 只在 mediaserverd 里生效，避免影响其它 App 的视频处理
static BOOL IsMediaServerd(void) {
    static BOOL result;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *p = [[NSProcessInfo processInfo] processName];
        result = [p isEqualToString:@"mediaserverd"];
    });
    return result;
}

// VCam 给 VTPixelTransferSession 设的是 "CropSourceToCleanAperture"（只截左上角、不缩放）
// 这里在设置生效前把它换成 "Letterbox"（等比缩放到完整可见，四周补边）
%hookf(int, VTSessionSetProperty, VTSessionRef session, CFStringRef key, CFTypeRef value) {
    if (IsMediaServerd() && key && value) {
        if (CFGetTypeID(key) == CFStringGetTypeID() && CFGetTypeID(value) == CFStringGetTypeID()) {
            if (CFEqual(key, CFSTR("ScalingMode"))) {
                if (CFEqual(value, CFSTR("CropSourceToCleanAperture"))) {
                    value = (CFTypeRef)CFSTR("Letterbox");
                }
            }
        }
    }
    return %orig;
}
