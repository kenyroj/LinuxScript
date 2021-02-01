# importing the required modules
import os
import sys
import time
import datetime
import stat
from pathlib import Path

#path = "/data/bsp_server/Share"
DefaultPath = "/data/Share"
DefaultDays = 30
DefaulsDel = 0

class MngFile(object):
    FullName = "";
    LADate = datetime.time(0, 0);
    Bytes = 0;

class MngDir(object):
    FullName = "";
    LADate = datetime.time(0, 0);

class MainMng(object):
    Files = []
    Dirs = []
    TotalBytes = 0
    def DeleteFiles(self, IsRealDel):
        for I in self.Dirs:
            print("ToDeleteDir: ",I.FullName)
            if IsRealDel == 1: os.rmdir(I.FullName)
        for I in self.Files:
            print("ToDeleteFile: ",I.FullName)
            if IsRealDel == 1: os.remove(I.FullName)
    def DumpInfo(self):
        print ("======== Empty Dirs to remove ========")
        for I in self.Dirs:
            print (I.LADate.strftime("%Y-%m-%d %H:%M:%S")," - ",I.FullName)
        print ("======== Old files to remove ========")
        for I in self.Files:
            print (I.LADate.strftime("%Y-%m-%d %H:%M:%S")," - ",I.FullName)
    def Summary(self):
        print("=== Total empty folders To Delete:", len(self.Dirs))
        print("=== Total files To Delete:",len(self.Files))
        print("=== Total bytes To Release:", self.TotalBytes,", in MB: ",self.TotalBytes / (1024*1024))

    def AddFile(self, path):
        fstat = os.stat(path)
        F = MngFile();
        F.FullName = path
        #F.LADate = datetime.datetime.fromtimestamp(os.path.getctime(path))
        F.Bytes = fstat.st_size
        self.TotalBytes += fstat.st_size
        self.Files.append(F)
        return 0
    def AddDir(self, path):
        D = MngDir();
        D.FullName = path
        D.LADate = datetime.datetime.fromtimestamp(os.path.getctime(path))
        self.Dirs.append(D)
        return 0

def FileXDaysAgo(now, days, path):
    CTime = os.path.getctime(path)
    if CTime < now - days * 60 * 60 * 24:
        return True
    return False

def ShowManual():
    print("Usage: Need 2 args")
    print("     Arg1: Target path")
    print("     Arg2: X days ago")

# main function
def main():
    if len(sys.argv) != 1 and len(sys.argv) != 3 and len(sys.argv) != 4:
        ShowManual()
        exit(2)

    try: SearchPath = sys.argv[1]
    except: SearchPath = DefaultPath
    try: CheckDays = int(sys.argv[2])
    except: CheckDays = DefaultDays
    try: SearchPath = sys.argv[1]
    except: SearchPath = DefaultPath
    try: IsRealDel = int(sys.argv[3])
    except: IsRealDel = DefaulsDel

    MNG = MainMng()
    Now = time.time()

    # checking whether the file is present in path or not
    if os.path.exists(SearchPath):
        # iterating over each and every folder and file in the path
        for RootDir, SubDirs, Files in os.walk(SearchPath):
            # checking folder from the RootDir
            for EachD in SubDirs:
                FullPath = os.path.join(RootDir, EachD)
                # removing the empty folder
                if not os.listdir(FullPath): MNG.AddDir(FullPath)

            # checking the current directory files
            for EachF in Files:
                FullPath = os.path.join(RootDir, EachF)
                if Path(FullPath).is_symlink() and not Path(FullPath).exists(): MNG.AddFile(FullPath)

                # comparing the days
                if FileXDaysAgo(Now, CheckDays, FullPath): MNG.AddFile(FullPath)
    else:
        # Target file/folder is not found
        print("Input file: ",SearchPath," is not found")
        exit(1)

#    MNG.DumpInfo()
    MNG.DeleteFiles(IsRealDel)
    MNG.Summary()
    print ("SearchPath:",SearchPath)
    print ("CheckDays:", CheckDays)

if __name__ == '__main__':
	sys.exit(main())
