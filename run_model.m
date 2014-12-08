function [h, err] = run_model(X, y, model)
    unsupervised = {'gmm', 'k-means'};
    supervised = {'svm', 'nb', 'logreg', 'gda'};
    
    if any(ismember(supervised, model))
        num_files = length(y);
        h = zeros(1, num_files);
        errs = zeros(10,5);
        %all_errs = zeros(10,5);
        for i = 1:10
            % PERCENTAGE USED TO TRAIN: 70%
            rand_ind = randperm(length(y), floor(0.7*length(y)));
            not_rand_ind = setdiff(1:length(y), rand_ind);
            X_temp = X(rand_ind,:);
            y_temp = y(rand_ind,:);
            X_test = X(not_rand_ind,:);
            y_test = y(not_rand_ind,:);

            %LOOCV
    %         for i = 1:num_files
    %             X_temp = X;
    %             X_temp(i,:) = [];
    %             y_temp = y;
    %             y_temp(i) = [];
    %             X_test = X(i,:);
    %             y_test = y(i);
    % 
            if strcmp (model, 'svm')
                try
                    results = multisvm(X_temp, y_temp, X_test)
                catch err
                    results = zeros(length(y_test),1)
                end
            elseif strcmp (model,'logreg')
                [m, dev, stats] = mnrfit(X_temp, y_temp);
                results = mnrval(m, X_test);
                [max_val, results] = max(results,[],2);
            elseif strcmp (model,'nb')
                m = fitNaiveBayes(X_temp, y_temp, 'dist', 'normal');
                results = m.predict(X_test);
            elseif strcmp (model, 'gda')
                m = fitcdiscr(X_temp, y_temp);
                results = m.predict(X_test);
            end 
            %errs(i) = sum(y_test ~= results)/length(results);
            for j = 1:5
                ind = find(y_test==j);
                sum(y_test(ind) == results(ind))
                errs(i,j) = 1-(sum(y_test(ind)==results(ind))/length(ind));
            end
            %h = [results y_test];
        end
        err = mean(errs);
        %err = mean(errs,1)
% 
%             h(i) = results;
%         end
%         err = sum(y' ~= h)/length(h);
    elseif any(ismember(unsupervised, model))
        if strcmp(model,'gmm')
            max(y)
            gm = fitgmdist(X, max(y), 'SharedCov', true, 'CovType', 'diagonal');
            h = cluster(gm, X)';
       elseif strcmp(model,'k-means')
            [idx, C] = kmeans(X, max(y));
            h = idx';
        end
        
        % test all permutations of y, to see which cluster is which label
        min_err = 1;
        all_perms = perms(1:max(y));
        h_best = h;
        h_base = h;
        for i = 1:size(all_perms,1)
            h = -h_base;
            for j = 1:max(y)
                h(h==-j) = all_perms(i,j);
            end
            curr_err = sum(y' ~= h)/length(h);
            if curr_err < min_err
                min_err = curr_err;
                h_best = h;
            end
        end
        err = min_err;
        h = h_best;
    else
        h = zeros(length(y),1);
    end
end