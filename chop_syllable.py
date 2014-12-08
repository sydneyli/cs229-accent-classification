import os
import sys
import wave

# Assumes the TextGrid file was generated with setting 'Inskanttextgrid'
# was off and 'Insorttextgrid' was ON.
#
# As arguments, it takes first the output TextGrid file of syllables and
# second the name of the wav file to split.

fullwav = wave.open(sys.argv[2], 'r')
framerate = fullwav.getframerate()
sampwidth = fullwav.getsampwidth()

f = open(sys.argv[1])
lines = f.readlines()
numToks = lines[13].split()[-1]
baseline = 14;
word_num = 0
for syl in range(0, int(numToks)):
    text_line = 4*syl + baseline
    word_name = lines[text_line+3].split()[-1]
    if len(word_name) >  2:
        word_num = word_num+1
        xmin = float(lines[text_line+1].split()[-1])
        xmax = float(lines[text_line+2].split()[-1])
        
        fullwav.setpos( int(xmin * framerate) )
        name_of_new_wav = sys.argv[2][:-4]+'_'+str(word_num).zfill(2)+'.wav'
        new_wav = wave.open(name_of_new_wav, 'w')
        new_wav.setnchannels(1)
        new_wav.setsampwidth(sampwidth)
        new_wav.setframerate(framerate)
        new_wav.writeframes(fullwav.readframes(int(framerate*(xmax-xmin))))
print str(fullwav.getnframes()) + ' ... done'
