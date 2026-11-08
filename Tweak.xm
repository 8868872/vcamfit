#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <VideoToolbox/VideoToolbox.h>

#define LOGPATH "/var/mobile/Media/DCIM/vcamfit.log"

static void FLog(NSString *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    NSString *s = [[NSString alloc] initWithFormat:fmt arguments:ap];
    va_end(ap);
    FILE *f = fopen(LOGPATH, "a");
    if (f) {
        NSString *line = [NSString stringWithFormat:@"%@\n", s];
        fputs([line UTF8String], f);
        fclose(f);
    }
    NSLog(@"[VCamFit] %@", s);
}

static BOOL IsMS(void) {
    static BOOL r;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        r = [[[NSProcessInfo processInfo] processName] isEqualToString:@"mediaserverd"];
    });
    return r;
}

%ctor {
    FLog(@"=== VCamFit loaded in %@ ===", [[NSProcessInfo processInfo] processName]);
}

%hookf(int, VTSessionSetProperty, VTSessionRef session, CFStringRef key, CFTypeRef value) {
    if (IsMS() && key && CFGetTypeID(key) == CFStringGetTypeID()) {
        NSString *k = (__bridge NSString *)key;
        if ([k isEqualToString:@"ScalingMode"] && value && CFGetTypeID(value) == CFStringGetTypeID()) {
            NSString *v = (__bridge NSString *)value;
            FLog(@"ScalingMode = %@", v);
            if ([v isEqualToString:@"CropSourceToCleanAperture"]) {
                value = (CFTypeRef)CFSTR("Letterbox");
                FLog(@"--> forced Letterbox");
            }
        }
    }
    return %orig;
}
