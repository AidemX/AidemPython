#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import you_get

default_encoding = 'utf-8'
if sys.getdefaultencoding()!=default_encoding:
    reload(sys)
    sys.setdefaultencoding(default_encoding)


def check_source(url, proxy=None, username=None, password=None, path=None):
    info = {
        'path':path,
		'url':url,
		'username': username,
		'password': password,
		'proxy':proxy
	}
    result='[ky_source_downloader.py]: Check source w/ %s\n' % info

    #sys.argv=['you-get','-h'] # Show help
    sys.argv = ['you-get','-i',url] # List available video w/ formats
    #sys.argv=['you-get','-i','--debug',url] # List available video w/ formats in debug mode
    you_get.main()

    return result
	

def download_source(url, proxy=None, username=None, password=None, path=None):
    info = {
        'path':path,
		'url':url,
		'username': username,
		'password': password,
		'proxy':proxy
	}
    result='[ky_source_downloader.py]: Download source w/ %s\n' % info

    #sys.argv=['you-get','-h'] # Show help
    #sys.argv = ['you-get', '-i', url] # List available video w/ formats
    #sys.argv=['you-get','-i','--debug',url] # List available video w/ formats in debug mode
    #sys.argv=['you-get','-o',path,url] # Download & save video to path
    sys.argv=['you-get','--debug','-o',path,url] # Download & save video to path in debug mode
    you_get.main()

    return result
