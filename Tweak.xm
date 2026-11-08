#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <VideoToolbox/VideoToolbox.h>

static BOOL IsMediaServerd(void) {
    static BOOL r;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        r = [[[NSProcessInfo processInfo] processName] isEqualToString:@"mediaserverd"];
    });
    return r;
}

static void VLog(NSString *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    NSString *s = [[NSString alloc] initWithFormat:fmt arguments:ap];
    va_end(ap);
    NSLog(@"[VCamFit] %@", s);
}

%ctor {
    VLog(@"loaded in %@", [[NSProcessInfo processInfo] processName]);
}

%hookf(int, VTSessionSetProperty, VTSessionRef session, CFStringRef key, CFTypeRef value) {
    if (IsMediaServerd() && key && CFGetTypeID(key) == CFStringGetTypeID()) {
        NSString *k = (__bridge NSString *)key;
        if ([k isEqualToString:@"ScalingMode"] && value && CFGetTypeID(value) == CFStringGetTypeID()) {
            NSString *v = (__bridge NSString *)value;
            VLog(@"ScalingMode = %@", v);
            if ([v isEqualToString:@"CropSourceToCleanAperture"]) {
                value = (CFTypeRef)CFSTR("Letterbox");
                VLog(@"forced -> Letterbox");
            }
        }
    }
    return %orig;
}

%hookf(OSStatus, VTPixelTransferSessionTransferImage, VTPixelTransferSessionRef s, CVPixelBufferRef src, CVPixelBufferRef dst) {
    if (IsMediaServerd()) {
        static int n = 0;
        if (n < 40) {
            n++;
            size_t sw = CVPixelBufferGetWidth(src), sh = CVPixelBufferGetHeight(src);
            size_t dw = CVPixelBufferGetWidth(dst), dh = CVPixelBufferGetHeight(dst);
            VLog(@"transfer %zux%zu -> %zux%zu", sw, sh, dw, dh);
        }
    }
    return %orig;
}
