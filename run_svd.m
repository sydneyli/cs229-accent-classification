function [ft_ind] = run_svd(X, n_features)
    [m, n] = size(X);
    [U, S, V] = svd(X);
    
    % remove means
    X = X - repmat(mean(X, 2), 1, size(X, 2));
    
    coverage = cumsum(diag(S));
    coverage = coverage ./ max(coverage);
    [~, nEig] = max(coverage > 0.95);
    
    norms = zeros(n, 1);
    for i = 1:n
        norms(i) = norm(V(i, 1:nEig))^2;
    end
    
    [~, ft_ind] = sort(norms);
    ft_ind = ft_ind(1:min(n_features, size(ft_ind)))';
end