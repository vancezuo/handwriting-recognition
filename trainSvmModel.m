function [ model ] = trainSvmModel( trainX, trainY, type, func )
% TRAINSVMMODEL Trains a (multi-class) SVM model on data
%   Vance Zuo, STAT 365 Final Project

    if ~exist('type', 'var')
        type = '1vAll';
    end    
    if ~exist('func', 'var')
        func = @(X,y) fitcsvm(X, y, 'KernelFunction','RBF', ...
                              'KernelScale','auto', 'Standardize',true);
    end
    
    groups = length(unique(trainY));

    % Assume labels are number 1, 2, ..., groups;
    % train 1v1 or 1vAll models depending on type parameter.
    if strcmpi(type, '1v1')
        model = cell(groups);
        for i=1:groups
            for j=i+1:groups
                keep = (trainY==i | trainY==j);
                X = trainX(keep,:);
                y = trainY(keep,:);
                model{i,j} = func(X, y);
                % model{j,i} = model{i,j};
            end
        end
    else
        model = cell(groups,1);
        for i=1:groups
            y = trainY;
            y(trainY~=i) = groups+1;
            model{i} = func(trainX, y);
        end
    end
end

