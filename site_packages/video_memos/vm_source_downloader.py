#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from io import StringIO

import you_get
#import traceback


default_encoding = 'utf-8'
if sys.getdefaultencoding()!=default_encoding:
    reload(sys)
    sys.setdefaultencoding(default_encoding)

'''
class vm_std(object):
    def write(self, *args, **kw): pass
    def flush(self, *args, **kw): pass

sys.stdout = vm_std()
sys.stderr = vm_std()
'''


# Check source and return json as result
def check_source(url, proxy=None, username=None, password=None, debug=0):
    # Store the reference, in case you want to show things again in standard output
    old_stdout = sys.stdout

    # This variable will store everything that is sent to the standard output
    io_buffer = StringIO()
    sys.stdout = io_buffer

    # Here we can call anything we like, like external modules, and everything
    #   that they will send to standard output will be stored on "temp_result"
    # Print extracted URLs in JSON format in debug mode
    if debug:
        sys.argv = ['you-get','--json','--debug',url]
    else:
        sys.argv = ['you-get','--json',          url]
    you_get.main()

    # Redirect again the std output to screen
    sys.stdout = old_stdout

    # Get the stdout like a string and process it
    io_buffer.seek(0) # jump to the start
    result = io_buffer.read()

    io_buffer.close()
    #traceback.print_exc(file=sys.stdout)
    #sys.stdout.flush()

    if debug:
        info = {
            'url':url,
            'proxy':proxy,
            'username':username,
            'password':password
        }
        print('[ky_source_downloader.py] check_source(): Check source w/\ncmd: %s\ninfo: %s\nJSON RESULT: %s' % sys.argv, info, result)

    return result


# Download & save video to path
def download_source(path, url, name=None, fmt=None, proxy=None, username=None, password=None, debug=0):
    #sys.argv = ['you-get','-h'] # Show help
    #sys.argv = ['you-get','-o',path,url] # Download & save video to path
    #sys.argv = ['you-get','--debug','-o',path,url] # Download & save video to path in debug mode

    # Full version: ['you-get','--debug','-F',fmt,'-o',path,url]
    argv_list = ['you-get']
    if debug:
        argv_list.append('--debug')
    if name:
        argv_list.append('-O')
        argv_list.append(name)
    if fmt:
        argv_list.append('-F')
        argv_list.append(fmt)
    argv_list.extend(['-o',path,url])

    if debug:
        info = {
            'url':url,
            'format':fmt,
            'proxy':proxy,
            'username':username,
            'password':password,
            'path':path
	    }
        print('[ky_source_downloader.py] download_source(): Download source w/\ncmd: %s\ninfo: %s' % argv_list, info)

    sys.argv = argv_list
    you_get.main()

    return '[ky_source_downloader.py]: DONE.'


def stop_downloading(taskProgressFilePath, debug=0):
    you_get.common.vm_skip_downloading(debug)
    '''
    try:
        #execfile('vm_execfile.py')
        #exec(open('vm_execfile.py').read())
        sys.exit(1)
    except SystemExit:
        print("sys.exit was called but I'm proceeding anyway (so there!-).")
    print("so I'll print this, etc, etc")
    '''
    result = 'result'
    return result


def vm_skip_downloading(debug=0):
    if debug:
        print('SKIPPED DOWNLOADING!')
    skipped_downloading = True
    try:
        #execfile('vm_execfile.py')
        #exec(open('vm_execfile.py').read())
        sys.exit(1)
    except SystemExit:
        print("sys.exit was called but I'm proceeding anyway (so there!-).")
    print("so I'll print this, etc, etc")
