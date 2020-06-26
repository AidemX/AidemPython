# PythonForVideoMemos

Python iOS framework for Video Memos app.

## Usage

1. Enter folder "site_packages" to pull latest source for each package.

  **NOTE**: For 3rd party package repos, make sure their branch is `video_memos_ios`.

2. Copy latest Python site pkgs from "site_packages" to "PythonForVideoMemos/python/lib/python3.8/site-packages"

  $ ./apply_latest_site_packages.sh

3. Add libs folder "PythonForVideoMemos" to Xcode project w/ "Create groups" option.

4. Extend the added group, remove references of the "python" folder from "PythonForVideoMemos" (just leave those *.a files there).

5. Re-add "python" folder back w/ "Create folder references" option.

  Tips:
  - This step makes sure those included lib files will be grouped under compiled app package.
  - Make sure no *.pyc files added.

6. Add required *.tbd files:

  4.1. Select project target
  4.2. Select "Build Phases"
  4.3. Extend "Link Binary With Libraries" section
  4.4. Add files: libsqlite3.tbd, libz.tbd

7. Update Project Settings:

  - HEADER_SEARCH_PATHS:  Add '$(PROJECT_DIR)/path/to/PythonForVideoMemos/python' (recursive)
  - LIBRARY_SEARCH_PATHS: Add '$(PROJECT_DIR)/path/to/PythonForVideoMemos'    (non-recursive)

8. Disable bitcode for iOS target:

Go to project settings, set `ENABLE_BITCODE` to NO.

Note: For iOS apps, bitcode is the default, but optional. For watchOS and tvOS apps, bitcode
is required. If you provide bitcode, all apps and frameworks in the app bundle (all targets 
in the project) need to include bitcode.

[Further Reading about bitcode](https://help.apple.com/xcode/mac/current/#/devbbdc5ce4f)

## 3rd Party Packages for Python

If need to add 3rd party packages for Python, just add it under

> PythonForVideoMemos/python/lib/python3.8/site-packages/

README.txt under "site-packages" folder:

> This directory exists so that 3rd party packages can be installed here.
> Read the source for site.py for more details. 

And if need to test Python package, suggest using `venv`:

  $ python3 -m venv venv
  $ . venv/bin/activate

---

## Further Reading

### About *.a file

These static libs will be compile-time-linked.

- libpython3.a: Main cross-compiled Python lib for iOS, its related header & resource files are stored in "python" folder.

- [libffi.a](https://sourceware.org/libffi/): FFI stands for Foreign Function Interface. It is the popular name for the interface that allows code written in one language to call code written in another language.

- [libcrypto.a & libssl.a](https://wiki.openssl.org/index.php/Libcrypto_API): OpenSSL provides two primary libraries: libssl and libcrypto. The libcrypto library provides the fundamental cryptographic routines used by libssl. You can however use libcrypto without using libssl.

Tips: If want to take look at *.a file, use cmd (refer to ["Contents of a static library"](https://stackoverflow.com/questions/3757108/contents-of-a-static-library)):

  $ nm libxxx.a | less

### About *.tbd file

These files associate to related dynamic libs, which will be runtime-linked.

`.tbd` (Text-Based Dylib) files are new "text-based stub libraries", that provide a much more compact version of the stub libraries for use in the SDK, and help to significantly reduce its download size. Refer to ["Why Xcode 7 shows *.tbd instead of *.dylib?"](https://stackoverflow.com/questions/31450690/why-xcode-7-shows-tbd-instead-of-dylib).


---

## About Python Cross-Compile

Posts:

- ["Embedding Python in an iPhone app"](https://stackoverflow.com/questions/3691655/embedding-python-in-an-iphone-app)
- ["Cross Compiling Python for iOS"](http://www.srplab.com/en/files/others/compile/cross_compiling_python_for_ios.html)

Some related repos:

- [Python-Apple-support](https://github.com/beeware/Python-Apple-support)
- [Python-iOS-template](https://github.com/beeware/Python-iOS-template)
- [python-for-ios)](https://github.com/linusyang/python-for-ios)
- [python-embedded](https://github.com/albertz/python-embedded/)

- [iOS-Python-Project](https://github.com/clowwindy/iOS-Python-Project)
- [rubicon-objc](https://github.com/beeware/rubicon-objc)

Kivy

- [kivy-ios](https://github.com/kivy/kivy-ios)
- ["Programming Guide » IOS Prerequisites"](https://kivy.org/doc/stable/guide/packaging-ios-prerequisites.html#packaging-ios-prerequisites)
- ["Installation on OS X"](https://kivy.org/doc/stable/installation/installation-osx.html)
- ["Create a package for IOS"](https://kivy.org/doc/stable/guide/packaging-ios.html)
- ["Kivy-Installation"](https://www.bookstack.cn/read/Kivy-CN/01-Kivy-Installation.md)


---

## About Embed Python Programming

- ["Extending/Embedding FAQ"](https://python.readthedocs.io/en/latest/faq/extending.html)

---

### Troubleshoots

- [ld: warning: could not create compact unwind for _ffi_call_unix64](https://gitlab.haskell.org/ghc/ghc/-/issues/5019)

---

## Others

- ["Changes To Embedding Python Using Xcode 5.0"](https://developer.apple.com/library/archive/technotes/tn2328/_index.html)

