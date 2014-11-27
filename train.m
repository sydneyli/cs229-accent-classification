% you should probably change the below two paths
addpath('./229/cs229-accent-classification/lib/rastamat/');
audio_dir = './229/audio/samples';

files = dir([audio_dir '/*.wav']);
num_files = length(files);

d = {};
min_size = -1;
for f = 1:num_files % 1:length(files) 
    [d_curr, sr] = audioread(fullfile(audio_dir, files(f).name));
    if length(d_curr) < min_size || min_size == -1
        min_size = length(d_curr);
    end
    d{f} = d_curr(:,1);
end

% obtaining mfcc features
X = [];
for i = 1:num_files
    d_curr = d{i};
    d_curr = d_curr(1:min_size);
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

X = X';
correct = 0;
fp = 0;
fn = 0;

% LOOCV
gms = {};
h = [];
for i = 1:num_files
    first = [];
    if i > 1
        first = X(:,1:i-1);
    end
    last = [];
    if i < num_files
        last = X(:,i+1:end);
    end
    X2 = [first last];
    [idx, C] = kmeans(X2', 2);
    
    test = C*X(:,i);
    [m, ind] = min(C*X(:,i));
    h = [h ind(1)];
end

% gmm
%gm = fitgmdist(X', 2, 'SharedCov', true, 'CovType', 'diagonal');
%h = cluster(gm, X');

% kmeans
%[idx, C] = kmeans(X', 2);
%h = idx'

% calculate errors
for i = 1:num_files
    predict = h(i);
    if predict == 1
        if ~isempty(strfind(files(i).name, 'eng'))
            correct = correct + 1;
        else
            fp = fp + 1;
        end
    end
    if predict == 2
        if isempty(strfind(files(i).name, 'eng'))
            correct = correct + 1;
        else
            fn = fn + 1;
        end
    end
end
if (correct/num_files < 0.5)
    fp = correct - fp;
    fn = (num_files - correct) - fn;
    correct = num_files - correct
end

disp('correct classification %');
disp(correct/num_files);

disp('false positive');
disp(fp/correct);
disp('false negative');
disp(fn/(num_files-correct));