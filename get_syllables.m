function srate = getSamples(filename,windowsize,nsyl)
%%%   filename is the FULL pathname of the .wav file to be run.
%%%   windowsize is the the quasi-constant window size to test on.
%%%   nsyl is the maximum number of syllables to get, of which the n best 
%%%     ones are returned.
[Samp, srate] = audioread(filename, 'double');

LEN = size(Samp, 1); % length of clip in number of samples
lt = Samp(:,1);
rt = Samp(:,2);
if (nsyl <= 0)
    MAX_NUM_SYLLABLES = LEN;
else
    MAX_NUM_SYLLABLES = nsyl;
end

mean_samp_height = sum(rt)/LEN % sanity check: should be nearly zero.



end
