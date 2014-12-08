% you should probably change the below two paths
addpath('./lib/rastamat/');

disp('################retrieving file names');
[by_lang, by_syl, num_files] = get_sample_names('./all_samples');

err_by_syl = zeros(size(by_syl,1), 1);
hypotheses = zeros(size(by_syl,1), num_files)
% which syllables to use?
for syl = 1:size(by_syl,1)
    disp (['################# Analyzing syllable no. ' num2str(syl)]);
    k = length(by_lang); % # langs, # clusters
    
    disp ('    loading syllable data ... ');
    [d, sr] = load_samples(syl, by_syl, k);

    num_files = length(d);

    % obtaining mfcc features
    X = [];
    n_windows = 16;
    mm=[];
    for i = 1:num_files
        this_n_windows = n_windows;
        while(size(mm, 2) ~= n_windows-1)
            d1 = d{i};
            d{i} = d1(:,1);
            hoptime = length(d{i}) / (sr * this_n_windows);
            wintime = 2*hoptime;
            [mm,aspc] = melfcc(d{i}*3.3752, sr, ...
                'maxfreq', 8000, ...
                'numcep', 20, ...
                'nbands', 22, ...
                'fbtype', 'fcmel', ...
                'dcttype', 1, ...
                'usecmp', 1, ...
                'wintime', wintime, ...
                'hoptime', hoptime, ...
                'preemph', 0, ...
                'dither', 1);
            this_n_windows = this_n_windows + 0.5;
        end
        mm = reshape(mm, 1, size(mm,1) * size(mm,2) );
        X = [X; mm]; %1:floor(num_files/2))]; % arbitrary feature selection. better way to do this?
    end

    disp('    running svd to select features...');
    % run pca/svd to get best n features
    ft_ind = run_svd(X, 16);
    X_orig = X;
    X = X(:, ft_ind);

    % generating array of hypotheses
    start = 1;
    y = zeros(num_files,1);
    for i = 1:k
        samples = by_syl{syl, i};
        y(start:start+length(samples)-1) = i;    
        start = start + length(samples);
    end

    disp('    training & testing ML model...');
    [h, err] = run_model(X, y, 'gmm')
    err_by_syl(syl) = err;
    hypotheses(syl,:) = h';
end

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