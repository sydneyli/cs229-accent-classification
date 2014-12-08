function [by_lang, by_syl, num_files] = get_sample_names(audio_dir)
    dirs = dir(audio_dir);
    dirs = dirs([dirs.isdir]); % remove files
    dirs = dirs(3:end); % remove '.' and '..' dirs
    dirs = {dirs.name};
    by_lang = {}; % organized by language
    syllables = 1:69; % which syllables do we have?
    by_syl = {}; % organized by syllable
    num_files = 0;
    for l = 1:length(dirs)
        lang_dir = [audio_dir '/' cell2mat(dirs(l))];
        files = dir([lang_dir, '/*.wav']);
        by_lang{l} = strcat([lang_dir '/'], {files.name});
        for s = 1:length(syllables)
            syl = num2str(syllables(s), '%02u');
            files = dir([lang_dir, '/*' syl '.wav']);
            if length(files) > 100
                rand_ind = randperm(length(files));
                rand_ind = rand_ind(1:100);
                files = files(rand_ind);
            end
            by_syl{s, l} = strcat([lang_dir '/'], {files.name}); 
        end
        num_files = num_files + length(files);
    end
end