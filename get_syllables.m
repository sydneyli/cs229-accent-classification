function retval = get_syllables(filename,windowsize,nsyl,Tau);
%%%   filename is the pathname of the .wav file to be run.
%%%   windowsize is the the quasi-constant window size to test on, >= 2.
%%%     windowsize should really be at least 10 or so.
%%%   nsyl is the maximum number of syllables to get, of which the n best 
%%%     ones are returned.
%%%   Tau is the degree of specificity to be examined in the window. Tau must
%%%     be between 2 and the windowsize. A large Tau will average the samples heavily.


    assert(windowsize > 1);
    
    [Samp, srate] = audioread(filename, 'double');
    
    LEN = size(Samp, 1); % length of clip in number of samples
    lt = Samp(:,1);
    if (size(Samp(2) == 2))
        rt = Samp(:,2);
        lt = 0.5 * (rt + lt); % if stereo, merge as average file.
    end
    
    % mean_samp_height = sum(rt)/LEN % sanity check: should be nearly zero.
    grads = zeros(windowsize + LEN - 1, 1);
    
    % for now, do as a for loop.  When comprehension is there, convert into 
    % matrix/vector operation.

    for frame=1-windowsize:LEN
        window = zeros(windowsize,1);
        for i=1:windowsize
            if (cur_samp>0 && cur_samp<=LEN)
                window(i) = abs(lt(frame+i));
            end
        end
        % ^^ Generates the values of the window.  Now, calculate the quasi-gradient.

    end

    if (nsyl <= 0)
        retval = grads;
    else
        [values, indices] = sort(grads, 'descend'); 
        % sort gradients by most massive to least
        syls = indices(1:nsyl);
        retval = sort(syls, 'ascend');
        % return the IDs of where the n largest grads are, ie the syllable marks.
    end

