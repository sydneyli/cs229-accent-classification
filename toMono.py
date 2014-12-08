import os
import re

regex = re.compile('[a-zA-Z]*[0-9]*.wav')

for f in os.listdir('.'):
    if os.path.isfile(f):
        filename = re.search(regex, f)
        if filename != None:
            os.system('ffmpeg -i '+f+' -vn -ar 16000 -ac 1 -f wav '+f[:-4]+'_mono.wav')
