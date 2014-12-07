function [by_lang, by_syl, all_files] = get_sample_names(audio_dir)
    dirs = dir(audio_dir);
    dirs = dirs([dirs.isdir]); % remove files
    dirs = dirs(3:end); % remove '.' and '..' dirs
    dirs = {dirs.name};
    by_lang = {}; % organized by language
    syllables = {'09', '10', '11', '12'};
    by_syl = {}; % organized by syllable

    for l = 1:length(dirs)
        lang_dir = [audio_dir '/' cell2mat(dirs(l))];
        files = dir([lang_dir, '/*.wav']);
        by_lang{l} = strcat([lang_dir '/'], {files.name});
        for s = 1:length(syllables)
            syl = cell2mat(syllables(s));
            files = dir([lang_dir, '/*' syl '.wav']);
            by_syl{s, l} = strcat([lang_dir '/'], {files.name}); 
        end
    end
    all_files = dir([audio_dir '/*.wav']);
end