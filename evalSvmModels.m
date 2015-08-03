function [ eval ] = evalSvmModels( models, trainX, trainY, testX, testY )
% EVALMODELS Evaluates multiple SVM models on predicted vs. actual data.
%   Vance Zuo, STAT 365 Final Project

    evalOneModel = @(x) evalSvmModel(x, trainX, trainY, testX, testY);

    [depth, rows, cols] = size(models);
    
    eval = cell(depth, rows, cols);    
    for k=1:depth
        for i=1:rows
            for j=1:cols
                eval{k,i,j} = evalOneModel(models{k,i,j});
            end
        end
    end

end

function [ eval ] = evalSvmModel(model, trainX, trainY, testX, testY)

    [p, s] = testSvmModel(model, trainX);
    [a, f, c] = evalModel(trainY, p);
    eval.train.predictions = p;
    eval.train.scores = s;
    eval.train.accuracy = a;
    eval.train.fscore = f;
    eval.train.confusion = c;

    [p, s] = testSvmModel(model, testX);
    [a, f, c] = evalModel(testY, p);
    eval.test.predictions = p;
    eval.test.scores = s;
    eval.test.accuracy = a;
    eval.test.fscore = f;
    eval.test.confusion = c;
end

