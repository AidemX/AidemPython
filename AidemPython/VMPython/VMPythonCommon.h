//
//  VMPythonCommon.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#ifndef VMPythonCommon_h
#define VMPythonCommon_h

#ifndef DEBUG
  #define VMPythonLog(__FORMAT__, ...);
  #define VMPythonLogWithColor(fg, type, __FORMAT__, ...);
  #define VMPythonLogCritical(__FORMAT__, ...);
  #define VMPythonLogError(__FORMAT__, ...);
  #define VMPythonLogWarn(__FORMAT__, ...);
  #define VMPythonLogNotice(__FORMAT__, ...);
  #define VMPythonLogSuccess(__FORMAT__, ...);
  #define VMPythonLogDebug(__FORMAT__, ...);

#else
  #define kVMPythonLogTypeCritical @"❌ CRITICAL"
  #define kVMPythonLogTypeError    @"🔴 ERROR"
  #define kVMPythonLogTypeWarn     @"⚠️ WARN"
  #define kVMPythonLogTypeNotice   @"🔵 NOTICE"
  #define kVMPythonLogTypeSuccess  @"✅ SUCCESS"
  #define kVMPythonLogTypeDebug    @"🎯 DEBUG"
  //#define NSLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
  //#define VMPythonLog(__FORMAT__, ...) NSLog((XCODE_COLORS_ESCAPE @"fg114,142,200;" __FORMAT__ XCODE_COLORS_RESET), ##__VA_ARGS__)
  #define VMPythonLog(__FORMAT__, ...) NSLog((@"%s L%d " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
  // Since Xcode 8, it does not support related plugin any more.
  //#define VMPythonLogWithColor(color, type, __FORMAT__, ...) NSLog((XCODE_COLORS_ESCAPE color @"%s L%d %@: " XCODE_COLORS_RESET __FORMAT__), __PRETTY_FUNCTION__, __LINE__, type, ##__VA_ARGS__)
  #define VMPythonLogWithColor(color, type, __FORMAT__, ...) NSLog((@"%@ %s L%d: " __FORMAT__), type, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
  #define VMPythonLogCritical(__FORMAT__, ...) VMPythonLogWithColor(@"bg255,70,71;",  kVMPythonLogTypeCritical, __FORMAT__, ##__VA_ARGS__)
  #define VMPythonLogError(__FORMAT__, ...)    VMPythonLogWithColor(@"fg255,70,71;",  kVMPythonLogTypeError,    __FORMAT__, ##__VA_ARGS__)
  #define VMPythonLogWarn(__FORMAT__, ...)     VMPythonLogWithColor(@"fg255,147,0;",  kVMPythonLogTypeWarn,     __FORMAT__, ##__VA_ARGS__)
  #define VMPythonLogNotice(__FORMAT__, ...)   VMPythonLogWithColor(@"fg0,178,255;",  kVMPythonLogTypeNotice,     __FORMAT__, ##__VA_ARGS__)
  #define VMPythonLogSuccess(__FORMAT__, ...)  VMPythonLogWithColor(@"fg74,210,87;",  kVMPythonLogTypeSuccess,  __FORMAT__, ##__VA_ARGS__)
  #define VMPythonLogDebug(__FORMAT__, ...)    VMPythonLogWithColor(@"fg152,181,79;", kVMPythonLogTypeDebug,    __FORMAT__, ##__VA_ARGS__)
  //🎾
#endif


typedef NS_ENUM(NSInteger, VMPythonDownloadProcessStatus) {
  VMPythonDownloadProcessStatusUnknown = 0,
  VMPythonDownloadProcessStatusNone,
  VMPythonDownloadProcessStatusWaiting,
  VMPythonDownloadProcessStatusPaused,
  VMPythonDownloadProcessStatusDownloading,
  VMPythonDownloadProcessStatusDownloadSucceeded,
  VMPythonDownloadProcessStatusDownloadFailed,
};

#endif /* VMPythonCommon_h */
