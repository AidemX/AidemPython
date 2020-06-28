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


def check_source(url, proxy=None, username=None, password=None, debug=0):
    if debug:
        info = {
		    'url':url,
		    'proxy':proxy,
		    'username':username,
		    'password':password
	    }
        print('[ky_source_downloader.py]: Check source w/ args:\n%s\n' % info)

    # Store the reference, in case you want to show things again in standard output
    old_stdout = sys.stdout

    # This variable will store everything that is sent to the standard output
    io_buffer = StringIO()
    sys.stdout = io_buffer

    # Here we can call anything we like, like external modules, and everything
    #   that they will send to standard output will be stored on "temp_result"
    #sys.argv = ['you-get','-h'] # Show help
    #sys.argv = ['you-get','-i',url] # List available video w/ formats
    #sys.argv = ['you-get','-i','--debug',url] # List available video w/ formats in debug mode

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
        print('cmd: %s' % sys.argv)
        print('[ky_source_downloader.py]:\nJSON RESULT: %s' % result)
    
    return result
	

def download_source(path, url, fmt=None, proxy=None, username=None, password=None, debug=0):
    info = {
		'url':url,
        'format':fmt,
		'proxy':proxy,
		'username':username,
		'password':password,
        'path':path
	}
    result = '[ky_source_downloader.py]: Download source w/ %s\n' % info
    #print('[ky_source_downloader.py]: Download source w/ args:\n%s\n' % info)
    print(result)
   
    # Download & save video to path
    #sys.argv = ['you-get','-h'] # Show help
    #sys.argv = ['you-get','-o',path,url] # Download & save video to path
    #sys.argv = ['you-get','--debug','-o',path,url] # Download & save video to path in debug mode

    if debug:
        if not fmt:
            sys.argv = ['you-get','--debug',         '-o',path,url] 
        else:
            sys.argv = ['you-get','--debug','-F',fmt,'-o',path,url]
    else:
        if not fmt:
            sys.argv = ['you-get',         '-o',path,url] 
        else:
            sys.argv = ['you-get','-F',fmt,'-o',path,url]

    you_get.main()
    
    if debug:
        print('cmd: %s' % sys.argv)

    return result


def debug_download_progress(url):
    result = '[ky_source_downloader.py]: Debug download progress w/ %s\n' % url
    print(result)
