function [ labels, scores ] = testSvmModel( model, X )
%TESTSVMMODEL Predicts labels of data based on SVM model.
%   Vance Zuo, STAT 365 Final Project
    
    groups = size(model,1);

    % Assume model comes from trainSvmModel.
    % Square array => 1v1 model, else => 1vAll model.
    if groups == size(model,2) 
        % Get winner for each combination.
        pred = zeros(nchoosek(groups,2), size(X,1));
        pred_i = 1;
        for i=1:groups
            for j=i+1:groups
                pred(pred_i,:) = predict(model{i,j}, X)';
                pred_i = pred_i + 1;
            end
        end
        % Label = most common winner acros combinations.
        if size(pred,1) > 1
            [~, ~, modes] = mode(pred); 
            labels = cellfun(@(x) x(randi(numel(x))), modes)';
        else
            labels = pred';
        end
        scores = histc(pred, 1:groups)';
    else
        % Get scores/probabilities for each class.
        scores = zeros(groups, size(X,1));
        for i=1:groups
            [~, rating] = predict(model{i}, X);
            scores(i,:) = rating(:,1);
        end
        % Labels = class with highest score.
        [scores, labels] = max(scores);
        labels = labels';
        scores = scores';
    end

end

