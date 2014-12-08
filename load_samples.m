function [d, sr] = load_samples(syl, by_syl, k)
    d= {};
    srs = [];
    min_size = -1;
    start = 1;
    for l = 1:k
        files = by_syl{syl, l};
        for f = 1:length(files)
            [d_curr, sr] = audioread(cell2mat(files(f)));
            % normalize audio
            d_curr = d_curr / max(abs(d_curr));
            srs(start) = sr;
            d{start} = d_curr;
            start = start + 1;
        end
    end

    % resample files @ highest sampling rate
    sr = max(srs);
    min_size = -1;
    for i = 1:length(d)
            if min_size == -1 || length(d{i}) < min_size
                min_size = length(d{i});
            end
        d{i} = resample(d{i}, sr, srs(i));
    end

    % optimally splices each sound sample
%     for i = 1:length(d)
%         sample = d{i};
%         max_start = 1;
%         max_avg = mean(abs(sample(1:min_size)));
%         for start = 2:(length(sample) - min_size)
%             avg = mean(abs(sample(start:(start+min_size-1))));
%             if avg > max_avg 
%                 max_start = start;
%                 max_avg = avg;
%             end
%         end
%         d{i} = sample(max_start:(max_start + min_size-1));
%     end
end