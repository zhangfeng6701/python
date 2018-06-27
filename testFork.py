import os

def myfork():
    pid = os.getpid()
    ppid = os.getppid()
    if pid == 0:
        print('This is child',pid)
        print('This is parent',ppid)
    else:
        print('This is parent%d',ppid,pid)
        
        
        
if __name__ == '__main__':
        myfork()
        dir(os)