function retval = get_syllables(filename,windowsize,nsyl,granularity,Tau)
%%%   filename is the pathname of the .wav file to be run.
%%%   windowsize is the the quasi-constant window size to test on, >= 2.
%%%     windowsize should really be at least 10 or so.
%%%   nsyl is the maximum number of syllables to get, of which the n best 
%%%     ones are returned.
%%%   Tau is the degree of specificity to be examined in the window. Tau must
%%%     be between 0 and 1, and it specifies how to weight values. Use:
%%%     1 for no weighting, near 0 for heavy weighting.
%%%     Intuitively, Tau creates a bowl-shaped near-distribution (ie, it increases the
%%%     mean slightly) with 1/Tau at the first sample in the window, 1 at the sample
%%%     at about the 1/4 mark, Tau at the middle sample, 1 at the 3/4 mark and 1/Tau at end.
%%%   Granularity is a measure of how much to space windows from each other.  It is 
%%%     measured in seconds, ie 0.05 means the starts of windows are spaced 0.05 secs apart.
%%%     Note that this has no effect on the size of the window; hence, this program outputs
%%%     a value of a ratio between the two.  Single-digit fractions are sensible.
%%%
%%%  Suggested values: 
%%%   --windowsize should be in the high 0.1s or 0.01s. Smaller values are prone to small or
%%%     insignificant peaks. Windowsize is the trickiest parameter, since it is not as intuitive.
%%%     For windowsize, estimate it by pulling up the waveform and guessing at how long it 
%%%     takes a syllable to go from silent to the maximum amplitude, plus some buffering space. 
%%%   --nsyl is really up to you.  Depends on your application.  A sensible amount is between
%%%     2 and 10 syllables per second.  Note that 0 or less will return every quasi-gradient.
%%%   --Tau is between 0 and 1.  I have not studied how or even if it makes any difference
%%%     in the result, so if in doubt, use 0.8 or so. It has had little or no effect on tests.
%%%   --Granularity is also tricky in the way that windowsize is, but it is also potentially more
%%%     easily remedied.  If you start with a small granularity and a high number of syllables 
%%%     from nsyl, you may result in a large number of indicators pointing at about the same point
%%%     in time, so you can subsequently reduce the number of syllables and increase the 
%%%     granularity until an adequate balance is reached.  Too high a granularity will/can miss
%%%     syllables entirely.
%%%     eg get_syllables('english25_5secs.wav',0.01,15,0.05,1) works pretty 


%%%  TODO: needs a *working* normalizing strategy to ignore "loud" words' weight.

    [Samp, srate] = audioread(filename, 'double');
    LEN = size(Samp, 1); % length of clip in number of samples

    granularity = granularity * srate;
    windowsize = windowsize * srate;
    assert(Tau>0 && Tau <=1);
    assert(nsyl < windowsize, nsyl < granularity);
    assert(windowsize > 1);
    assert(granularity > 0 && granularity < LEN);


    Window_Size_to_Granularity_Ratio = windowsize/granularity

    lt = Samp(:,1);
    if (size(Samp(2) == 2))
        rt = Samp(:,2);
        lt = 0.5 * (rt + lt); % if stereo, merge as average file.
    end
    
    half = ceil(windowsize/2);
    avg_samp_magn = sum(abs(lt))/LEN
    
    Tau_curve = ones(windowsize,1);
    for i=1:half-1
        Tau_curve(i) = Tau^(4*(i/windowsize)-1);
    end
    for i=half:windowsize
        Tau_curve(i) = Tau^(4*(-(i-1)/windowsize+0.75));
    end
    if (mod(windowsize,2) == 0)
        Tau_curve(floor(windowsize/2)) = Tau;
    end
    % While the Tau curve will skew the arithmetic &| geometric means, this
    % is constant.  So, it can be safely ignored. sum(Tau_curve)

    % for now, do the following as a for loop. Once the comprehension is there, 
    % convert into appropriate (efficient) matrix/vector operation.

    % mean_samp_height = sum(rt)/LEN   % <- sanity check: should be nearly zero.
    grads = zeros(windowsize - LEN + 1, 1);
    
    for frame=windowsize:100:LEN-windowsize
        window = zeros(windowsize,1);
        for i=1:windowsize
            window(i) = abs(lt(frame+i));
        end
        % ^^ Generates the values of the window.  Now, calculate the quasi-gradient.
        % Convolute the Tau curve with the window:
        weighted_window = window * Tau_curve(1);
        % And now find the difference between the two halves.  Most windows will sum to
        % about zero, but ones with large amplitude spikes will have a large difference.
        d1 = sum(weighted_window(1:half));
        d2 = sum(weighted_window(half+1:windowsize));
        grads(frame) = (d2-d1)/(1+d1+d2); % <- NOT abs: we want _starts_ of words, ie spikes, not drops.
        % ^^ the (d1+d2) is supposed to normalize the grads relative to their own height.
        if (1+d1+d2 < avg_samp_magn)
            grads(frame) = 0;
        end
    end
    
    if (nsyl <= 0)
        retval = grads;
    else
        [values, indices] = sort(grads, 'descend'); 
        % ^ sort gradients by most massive to least
        syls = indices(1:nsyl);
        retval = sort(syls, 'ascend') / srate;
        % ^ return the time IDs of where the n largest grads are, ie the n most distinctive syllables.
    end
end

