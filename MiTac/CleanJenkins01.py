#/usr/bin/python3
import sys
import subprocess

DelMaps = {
    '/data/Images/n677-android-alpha-dev/continuous/' : '45',
    '/data/Images/n685-android-dev/continuous/' : '45',
    '/data/Images/n689-android-dev/continuous/' : '45',
    
    '/data/Images/n677-android-alpha-dev/custom/' : '14',
    '/data/Images/n685-android-dev/custom/' : '14',
    '/data/Images/n689-android-dev/custom/' : '14'

}


def main():
    try: IsReallyDelete = sys.argv[1]
    except IndexError: IsReallyDelete='0'
    
    for EachD in DelMaps.items():
        print("[1;33m ==== Handling folder[%s][%s]: %s [m" % (EachD[1], IsReallyDelete, EachD[0]))
        process = subprocess.Popen([ 'python3', '/home/aken.hsu/script/DeleteOldFile.py', EachD[0], EachD[1]], stdout=subprocess.PIPE)
        output, error = process.communicate()

if __name__ == '__main__':
    sys.exit(main())