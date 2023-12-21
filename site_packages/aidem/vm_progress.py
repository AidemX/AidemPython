#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os

class VMDownloadingProgress:
    def __init__(self, output_dir, total_size, total_pieces=1):
        #self.total_size = total_size
        #self.total_pieces = total_pieces
        self.current_piece = 1
        self.received = 0
        #self.speed = ''
        #self.last_updated = time.time()
        #self.progress_filepath = output_filepath.rsplit('.', 1)[0] + '.progress'
        self.progress_filepath = output_dir + '/vm_progress'

    def progress_file_exists(self):
        return os.path.exists(self.progress_filepath)
        
    def update(self):
        #percent = round(self.received / self.total_size, 2)
        #sys.stdout.write('\r' + format(percent), flush=True)
        #print(format(percent))
        if os.path.exists(self.progress_filepath):
            with open(self.progress_filepath, "w") as output:
                #output.seek(0) # rewind
                output.write(format(self.received))

    def update_received(self, n):
        self.received += n
        '''
        time_diff = time.time() - self.last_updated
        bytes_ps = n / time_diff if time_diff else 0
        if bytes_ps >= 1024 ** 3:
            self.speed = '{:4.0f} GB/s'.format(bytes_ps / 1024 ** 3)
        elif bytes_ps >= 1024 ** 2:
            self.speed = '{:4.0f} MB/s'.format(bytes_ps / 1024 ** 2)
        elif bytes_ps >= 1024:
            self.speed = '{:4.0f} kB/s'.format(bytes_ps / 1024)
        else:
            self.speed = '{:4.0f}  B/s'.format(bytes_ps)
        self.last_updated = time.time()
        '''
        self.update()

    def update_piece(self, n):
        self.current_piece = n

    def done(self):
        print()
