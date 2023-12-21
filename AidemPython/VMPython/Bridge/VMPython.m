//
//  VMPython.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPython.h"

#import "VMPythonCommon.h"
// Lib
#import "Python.h"


@interface VMPython ()

@property (nonatomic, assign, readwrite) BOOL initialized;

@end


@implementation VMPython

+ (instancetype)sharedInstance
{
  static VMPython *_sharedVMPython = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMPython = [[VMPython alloc] init];
  });
  
  return _sharedVMPython;
}

#pragma mark - Private

void load_custom_builtin_importer(void) {
  static const char *custom_builtin_importer = \
  "import sys, imp, types\n" \
  "from os import environ\n" \
  "from os.path import exists, join\n" \
  "try:\n" \
  "    # python 3\n"
  "    import _imp\n" \
  "    EXTS = _imp.extension_suffixes()\n" \
  "    sys.modules['subprocess'] = types.ModuleType(name='subprocess')\n" \
  "    sys.modules['subprocess'].PIPE = None\n" \
  "    sys.modules['subprocess'].STDOUT = None\n" \
  "    sys.modules['subprocess'].DEVNULL = None\n" \
  "    sys.modules['subprocess'].CalledProcessError = Exception\n" \
  "    sys.modules['subprocess'].check_output = None\n" \
  "except ImportError:\n" \
  "    EXTS = ['.so']\n"
  "# Fake redirection to supress console output\n" \
  "if environ.get('KIVY_NO_CONSOLE', '0') == '1':\n" \
  "    class fakestd(object):\n" \
  "        def write(self, *args, **kw): pass\n" \
  "        def flush(self, *args, **kw): pass\n" \
  "    sys.stdout = fakestd()\n" \
  "    sys.stderr = fakestd()\n" \
  "# Custom builtin importer for precompiled modules\n" \
  "class CustomBuiltinImporter(object):\n" \
  "    def find_module(self, fullname, mpath=None):\n" \
  "        # print(f'find_module() fullname={fullname} mpath={mpath}')\n" \
  "        if '.' not in fullname:\n" \
  "            return\n" \
  "        if not mpath:\n" \
  "            return\n" \
  "        part = fullname.rsplit('.')[-1]\n" \
  "        for ext in EXTS:\n" \
  "           fn = join(list(mpath)[0], '{}{}'.format(part, ext))\n" \
  "           # print('find_module() {}'.format(fn))\n" \
  "           if exists(fn):\n" \
  "               return self\n" \
  "        return\n" \
  "    def load_module(self, fullname):\n" \
  "        f = fullname.replace('.', '_')\n" \
  "        mod = sys.modules.get(f)\n" \
  "        if mod is None:\n" \
  "            # print('LOAD DYNAMIC', f, sys.modules.keys())\n" \
  "            try:\n" \
  "                mod = imp.load_dynamic(f, f)\n" \
  "            except ImportError:\n" \
  "                # import traceback; traceback.print_exc();\n" \
  "                # print('LOAD DYNAMIC FALLBACK', fullname)\n" \
  "                mod = imp.load_dynamic(fullname, fullname)\n" \
  "            sys.modules[fullname] = mod\n" \
  "            return mod\n" \
  "        return mod\n" \
  "sys.meta_path.insert(0, CustomBuiltinImporter())";
  PyRun_SimpleString(custom_builtin_importer);
}

#pragma mark - Public

- (void)enterPythonEnv
{
  if (self.isInitialized) {
    return;
  }
  
  // Change the executing path to YourApp
  //chdir("AidemPythonDemo");
  
  // Special environment to prefer .pyo, and don't write bytecode if .py are found
  // because the process will not have a write attribute on the device.
  //
  // REF:
  //   https://docs.python.org/3/c-api/init.html
  //
  putenv("PYTHONOPTIMIZE=2");
  putenv("PYTHONDONTWRITEBYTECODE=1");
  putenv("PYTHONNOUSERSITE=1");
  putenv("PYTHONPATH=.");
  putenv("PYTHONUNBUFFERED=1");
  putenv("LC_CTYPE=UTF-8");
#ifdef DEBUG
//  putenv("PYTHONVERBOSE=1");
#endif // END #ifdef DEBUG
  // putenv("PYOBJUS_DEBUG=1");
  
  /*
  // Kivy environment to prefer some implementation on iOS platform
  putenv("KIVY_BUILD=ios");
  putenv("KIVY_NO_CONFIG=1");
  putenv("KIVY_NO_FILELOG=1");
  putenv("KIVY_WINDOW=sdl2");
  putenv("KIVY_IMAGE=imageio,tex,gif");
  putenv("KIVY_AUDIO=sdl2");
  putenv("KIVY_GL_BACKEND=sdl2");
   */
  
  // IOS_IS_WINDOWED=True disables fullscreen and then statusbar is shown
  putenv("IOS_IS_WINDOWED=False");
  
  //#ifndef DEBUG
  putenv("KIVY_NO_CONSOLELOG=1");
  //#endif
  
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  resourcePath = [resourcePath stringByAppendingPathComponent:@"python"];
  VMPythonLogNotice(@"resourcePath: %@", resourcePath);
#if PY_MAJOR_VERSION == 2
  wchar_t *pythonHome = (wchar_t *)[resourcePath UTF8String];
  VMPythonLogNotice(@"PythonHome is: %s", pythonHome);
  Py_SetPythonHome(pythonHome);
#else
  NSString *pythonHome = [NSString stringWithFormat:@"PYTHONHOME=%@", resourcePath, nil];
  putenv((char *)[pythonHome UTF8String]);
  
  NSString *pythonPath = [NSString stringWithFormat:@"PYTHONPATH=%@:%@/lib/python3.8/:%@/lib/python3.8/site-packages:.", resourcePath, resourcePath, resourcePath, nil];
  putenv((char *)[pythonPath UTF8String]);
  
  NSString *tmpPath = [NSString stringWithFormat:@"TMP=%@/tmp", resourcePath, nil];
  putenv((char *)[tmpPath UTF8String]);
#endif
  
  // Initialize Python Environment
  VMPythonLogNotice(@"Initializing Python ...");
  Py_Initialize();
  // If other modules are using the thread, we need to initialize them before.
  PyEval_InitThreads();
  
  self.initialized = Py_IsInitialized();
#ifdef DEBUG
  if (self.isInitialized) {
    VMPythonLogSuccess(@"Python Environment Initialization Succeeded.");
  } else {
    VMPythonLogError(@"Python Environment Initialization Failed.");
  }
#endif // END #ifdef DEBUG
  
  load_custom_builtin_importer();
}

- (void)quitPythonEnv
{
  if (self.isInitialized) {
    self.initialized = NO;
    Py_Finalize();
    VMPythonLogNotice(@"Python Finalize");
  }
}

@end
