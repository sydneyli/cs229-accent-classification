import os; import re
regex = re.compile('[a-zA-Z][0-9]*_mono.wav')
for f in os.listdir('.'):
    if os.path.isfile(f):
        filename = re.search(regex, f)
        if filename != None:
            os.system('cp text.txt '+f[:-4]+'.txt')
