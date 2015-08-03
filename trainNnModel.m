function [ net ] = trainNnModel( trainX, trainY, sizes )
% TRAINNNMODEL Trains a neural network model
%   Vance Zuo, CPSC 476 Final Project

    t = zeros(size(trainY,1), size(unique(trainY),1));
    for i=1:size(t,1)
        t(i,trainY(i)) = 1;
    end

    net = patternnet(sizes);
    net.divideFcn = 'divideint';
    net.divideParam.trainRatio = 0.8;
    net.divideParam.valRatio = 0.2;
    net.divideParam.testRatio = 0;
    net.trainParam.max_fail = 12;
    net.trainParam.showWindow = 0;
    
    net = train(net, trainX', t');    
    
end

