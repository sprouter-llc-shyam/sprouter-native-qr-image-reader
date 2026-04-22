#import "SprouterNativeQrImageReader.h"
#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <React/RCTConvert.h>

@implementation SprouterNativeQrImageReader 

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(readQRFromImage:(NSString *)source
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject)
{
  UIImage *image = [self loadImageFrom:source];
  if (!image) {
    reject(@"no_image", @"Unable to load image", nil);
    return;
  }

  CGImageRef cgImage = image.CGImage;
  if (!cgImage) {
    reject(@"cgimage_error", @"Invalid CGImage", nil);
    return;
  }

  VNDetectBarcodesRequest *request =
  [[VNDetectBarcodesRequest alloc] initWithCompletionHandler:
   ^(VNRequest * _Nonnull request, NSError * _Nullable error) {

    if (error) {
      reject(@"vision_error", error.localizedDescription, error);
      return;
    }

    NSMutableArray<NSString *> *results = [NSMutableArray new];

    for (VNBarcodeObservation *obs in request.results) {
      if (obs.symbology == VNBarcodeSymbologyQR &&
          obs.payloadStringValue != nil) {
        [results addObject:obs.payloadStringValue];
      }
    }

    resolve(results);
  }];

  request.symbologies = @[VNBarcodeSymbologyQR];

  VNImageRequestHandler *handler =
    [[VNImageRequestHandler alloc] initWithCGImage:cgImage
                                          options:@{}];

  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    NSError *err = nil;
    BOOL success = [handler performRequests:@[request] error:&err];
    if (!success || err) {
      reject(@"vision_perform_error", err.localizedDescription, err);
    }
  });
}

- (UIImage *)loadImageFrom:(NSString *)source
{
  if ([source hasPrefix:@"data:image"]) {
    NSArray *parts = [source componentsSeparatedByString:@","];
    if (parts.count < 2) return nil;

    NSData *data =
      [[NSData alloc] initWithBase64EncodedString:parts.lastObject
                                          options:0];
    if (!data) return nil;

    return [UIImage imageWithData:data];
  } else {
    NSString *path =
      [source stringByReplacingOccurrencesOfString:@"file://"
                                        withString:@""];
    return [UIImage imageWithContentsOfFile:path];
  }
}

@end
