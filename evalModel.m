function [ accuracy, fscore, confusion, precision, recall ] = ...
        evalModel(actual, pred, labels)
% EVALMODEL Evaluates model on predicted vs. actual data.
%   Vance Zuo, STAT 365 Final Project

    if ~exist('labels', 'var')
        labels = unique(actual)';
    end

    confusion = confusionmat(actual, pred);
    
    tp = zeros(size(labels,1),1);
    fp = zeros(size(labels,1),1);
    fn = zeros(size(labels,1),1);
    
    for i=labels
        tp(i) = confusion(i,i);
        fp(i) = sum(confusion(:,i)) - tp(i);
        fn(i) = sum(confusion(i,:)) - tp(i);
    end
    accuracy = sum(pred == actual) / size(actual,1);
    
    precision = mean(tp ./ (tp + fp));
    recall = mean(tp ./ (tp + fn));
    
    fscore = 2*precision*recall / (precision + recall);
end

