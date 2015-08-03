% Vance Zuo
% CPSC 476
% Final Project

%% Train NNs

if ~exist('trainData', 'var'), load('train.mat', 'trainData'); end
if ~exist('trainDataNoise', 'var'), load('extra.mat', 'trainDataNoise'); end
if ~exist('trainDataMedian', 'var'), load('extra.mat', 'trainDataMedian'); end
if ~exist('trainDataBlur', 'var'), load('extra.mat', 'trainDataBlur'); end

nnSizes = { 4 16 64 256 1024 [4 16] [16 64] [64 256] [256 1024] ...
            [16 4] [64 16] [256 64] [1024 256] [4 16 64] [16 4 64] ... 
            [16 64 256] [64 16 256] [64 256 1024] [256 64 1024] ...
            [64 16 4] [16 64 4] [256 64 16] [64 256 16] ... 
            [1024 256 64] [256 1024 64] };

trX = trainData(:,1:end-2);
trY1 = trainData(:,end-1);
trY2 = trainData(:,end);

xtrX = {[] trainDataNoise(:,1:end-2) trainDataMedian(:,1:end-2) ...
        trainDataBlur(:,1:end-2) };
xtrY1 = {[] trainDataNoise(:,end-1) trainDataMedian(:,end-1) ...
         trainDataBlur(:,end-1) };
xtrY2 = {[] trainDataNoise(:,end) trainDataMedian(:,end) ...
         trainDataBlur(:,end) };

rng('default');
nets1 = cell(size(xtrX,2), size(nnSizes,2));
nets2 = cell(size(xtrX,2), size(nnSizes,2));
for i=1:size(nets1,1)
    for j=1:size(nets1,2)
        nets1{i,j} = trainNnModel(trX, trY1, nnSizes{j});
        nets2{i,j} = trainNnModel(trX, trY2, nnSizes{j});
    end
end

save('nn.mat', 'nets1', 'nets2');
beep on; beep;

%% Test NNs

if ~exist('trainData', 'var'), load('train.mat', 'trainData'); end
if ~exist('testData', 'var'), load('test.mat', 'testData'); end
if ~exist('nets1', 'var'), load('nn.mat', 'nets1'); end
if ~exist('nets2', 'var'), load('nn.mat', 'nets2'); end

trX = trainData(:,1:end-2);
trY1 = trainData(:,end-1);
trY2 = trainData(:,end);

teX = testData(:,1:end-2);
teY1 = testData(:,end-1);
teY2 = testData(:,end);

eval1.train = cell(size(nets1));
eval1.test = cell(size(nets1));
eval2.train = cell(size(nets2));
eval2.test = cell(size(nets2));
for i=1:size(nets1,1)
    for j=1:size(nets1,2)
        eval1.train{i,j} = evalNnModels(nets1{i,j}, trX, trY1);
        eval1.test{i,j} = evalNnModels(nets1{i,j}, teX, teY1);

        eval2.train{i,j} = evalNnModels(nets2{i,j}, trX, trY2);
        eval2.test{i,j} = evalNnModels(nets2{i,j}, teX, teY2);
    end
end

save('nneval.mat', 'eval1', 'eval2');
beep on; beep;

%% Save NN metrics

if ~exist('eval1', 'var'), load('nneval.mat', 'eval1'); end
if ~exist('eval2', 'var'), load('nneval.mat', 'eval2'); end

savefile = @(name,x) dlmwrite(name, x, 'delimiter','\t');

% F-score/accuracy
out = cellfun(@(x) x.fscore, eval2.train);
savefile('results/nn-letter-train-fscore.txt', out);

out = cellfun(@(x) x.accuracy, eval2.train);
savefile('results/nn-letter-train-accuracy.txt', out);

out = cellfun(@(x) x.fscore, eval2.test);
savefile('results/nn-letter-test-fscore.txt', out);

out = cellfun(@(x) x.accuracy, eval2.test);
savefile('results/nn-letter-test-accuracy.txt', out);

out = cellfun(@(x) x.fscore, eval1.train);
savefile('results/nn-person-train-fscore.txt', out);

out = cellfun(@(x) x.accuracy, eval1.train);
savefile('results/nn-person-train-accuracy.txt', out);

out = cellfun(@(x) x.fscore, eval1.test);
savefile('results/nn-person-test-fscore.txt', out);

out = cellfun(@(x) x.accuracy, eval1.test);
savefile('results/nn-person-test-accuracy.txt', out);

% Confusion matrices
beep on; beep;
