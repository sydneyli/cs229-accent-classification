% you should probably change the below two paths
addpath('./lib/rastamat/');
audio_dir = './samples';

[by_lang, by_syl, all_files] = get_sample_names('./samples');
num_files = length(all_files);

% which syllables to use?
syl = 4;

k = length(by_lang); % # langs, # clusters
[d, sr] = load_samples(syl, by_syl, k);

num_files = length(d);

% obtaining mfcc features
X = [];
for i = 1:num_files
    d_curr = d{i};
    [mm,aspc] = melfcc(d_curr*3.3752, sr, ...
        'maxfreq', 8000, ...
        'numcep', 20, ...
        'nbands', 22, ...
        'fbtype', 'fcmel', ...
        'dcttype', 1, ...
        'usecmp', 1, ...
        'wintime', 0.032, ...
        'hoptime', 0.016, ...
        'preemph', 0, ...
        'dither', 1);
    mm = reshape(mm, 1, size(mm,1) * size(mm,2) );
    X = [X; mm(1:floor(num_files/2))]; % arbitrary feature selection
end

% gmm
gm = fitgmdist(X, k, 'SharedCov', true, 'CovType', 'diagonal');
h1 = cluster(gm, X)

% kmeans
[idx, C] = kmeans(X', k);
h2 = idx'

% 
% X = X';
% correct = 0;
% fp = 0;
% fn = 0;
% 
% % LOOCV
% gms = {};
% h = [];
% for i = 1:num_files
%     first = [];
%     if i > 1
%         first = X(:,1:i-1);
%     end
%     last = [];
%     if i < num_files
%         last = X(:,i+1:end);
%     end
%     X2 = [first last];
%     [idx, C] = kmeans(X2', 2);
%     
%     test = C*X(:,i);
%     [m, ind] = min(C*X(:,i));
%     h = [h ind(1)];
% end
% 
% % calculate errors
% for i = 1:num_files
%     predict = h(i);
%     if predict == 1
%         if ~isempty(strfind(files(i).name, 'eng'))
%             correct = correct + 1;
%         else
%             fp = fp + 1;
%         end
%     end
%     if predict == 2
%         if isempty(strfind(files(i).name, 'eng'))
%             correct = correct + 1;
%         else
%             fn = fn + 1;
%         end
%     end
% end
% if (correct/num_files < 0.5)
%     fp = correct - fp;
%     fn = (num_files - correct) - fn;
%     correct = num_files - correct
% end
% 
% disp('correct classification %');
% disp(correct/num_files);
% 
% disp('false positive');
% disp(fp/correct);
% disp('false negative');
% disp(fn/(num_files-correct));