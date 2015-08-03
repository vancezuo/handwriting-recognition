function [ eval ] = evalNnModels( net, X, y )
%EVALNNMODELS Evaluates NN multiple models on predicted vs. actual data.
%   Vance Zuo, CPSC 476 Final Project
    
    yhat = net(X');
    [~, yhat] = max(yhat);
    yhat = yhat';
    [a, f, c] = evalModel(y, yhat);

    eval.predictions = yhat;
    eval.accuracy = a;
    eval.fscore = f;
    eval.confusion = c;
end

