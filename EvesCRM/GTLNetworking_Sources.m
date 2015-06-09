#if defined(__has_feature) && __has_feature(objc_arc)
#error "This file needs to be compiled with ARC disabled."
#endif

//#import "HTTPFetcher/GTMGatherInputStream.m"
//#import "HTTPFetcher/GTMMIMEDocument.m"
//#import "HTTPFetcher/GTMReadMonitorInputStream.m"
//#import "HTTPFetcher/GTMHTTPFetcher.m"
//#import "HTTPFetcher/GTMHTTPFetcherLogging.m"
//#import "HTTPFetcher/GTMHTTPFetcherService.m"
//#import "HTTPFetcher/GTMHTTPFetchHistory.m"
//#import "HTTPFetcher/GTMHTTPUploadFetcher.m"

#import "Source//GTMGatherInputStream.m"
#import "Source/GTMMIMEDocument.m"
#import "Source/GTMReadMonitorInputStream.m"
#import "Source/GTMHTTPFetcher.m"
#import "Source/GTMHTTPFetcherLogging.m"
#import "Source/GTMHTTPFetcherService.m"
#import "Source/GTMHTTPFetchHistory.m"
#import "Source/GTMHTTPUploadFetcher.m"

//#import "OAuth2/GTMOAuth2Authentication.m"
#import "gtm-oauth2-master/Source/GTMOAuth2Authentication.m"
#import "gtm-oauth2-master/Source/GTMOAuth2SignIn.m"
#if TARGET_OS_IPHONE
  #import "gtm-oauth2-master/Source/Touch/GTMOAuth2ViewControllerTouch.m"
#elif TARGET_OS_MAC
  #import "gtm-oauth2-master/Source/Mac/GTMOAuth2WindowController.m"
#else
  #error Need Target Conditionals
#endif
