% Vance Zuo
% STAT 365
% Final Project

%% Load data

% Abbreviation of loadData (for brevity).
% This function divides image into tiles for faster data extraction.
loadDataAbbr = @(im,off,ref) loadData(im, 'rows',10, 'cols',7, ...
                                      'offset',off, 'reference',ref, ...
                                      'checktiles',true);

% Load data from 10 scanned images.               
imgData = zeros(70*10, 32*32); % prealloc

offs = [48 48; 49 48; 49 48; 48 48; 48 48; ...
        48 48; 48 48; 48 48; 48 48; 48 48];
refs = [52 40 32 32; 52 39 32 32; 52 40 32 32; 55 43 32 32; 56 44 32 32; ...
        52 44 32 32; 54 44 32 32; 52 40 32 32; 53 41 32 32; 54 40 32 32];
for i=1:10
    filename = sprintf('data/data-%02d.png', i);
    [im, map] = imread(filename);
    im = ind2gray(im, map);
    im = imresize(im, 1/4); % resize so letters fits in 32x32
    
    first = 70*(i-1)+1;
    last = 70*i;
    imgData(first:last,:) = loadDataAbbr(im, offs(i,:), refs(i,:));
end

% Normalize to [0, 1] range.
imgData = imgData ./ max(255, max(imgData(:)));

beep on; beep;
save('images.mat', 'imgData');

%% Visualize/save data
if ~exist('imgData', 'var'), load('images.mat', 'imgData'); end

% Save extracted data as tiled images.
figure;
iptsetpref('ImshowBorder','tight');
for i=1:70:700
    displayData(imgData, [32 32], 5, 14, i);
    saveas(gcf, sprintf('images/img-%03d-%03d.png', i, i+70));
end
close;

beep on; beep;

%% Label data
if ~exist('imgData', 'var'), load('images.mat', 'imgData'); end

% Data is preformatted so that indexes 
%   1-350 = person 1 handwriting,
%   350-700 = person 2's handwriting.
% Each person has 70 examples of a,b,c,d,e (=1,2,3,4,5) in order.
% New columns mark identity of handwriter and the letter written.
allData = imgData;
allData(:,end+1:end+2) = 0;
for i=1:2
    for j=1:5
        pos = 1 + (i-1)*350 + (j-1)*70;
        allData(pos:pos+69,end-1:end) = repmat([i j], 70, 1);
    end
end

beep on; beep;
save('data.mat', 'allData');

%% Randomly split into training/testing sets
if ~exist('allData', 'var'), load('data.mat', 'allData'); end

% For each of the 10 person, letter groups (70 examples each),
% randomly pick 40 for training, 30 for testing.
rng('default');
[trainData, testData] = splitData(allData, 10, [4 3]);

beep on; beep;
save('train.mat', 'trainData');
save('test.mat', 'testData');

%% Generate "extra" training data
% Adding/removing noise, blurring/sharpening, zooming

if ~exist('trainData', 'var'), load('train.mat', 'trainData'); end

% Abbreviation of genData (for brevity).
gen = @(func) genData(trainData, [32 32], func);

% "Extra" data consists of original, but modified via
%   Gaussian noise (0 mean, 0.01 variance),
%   Median filtering (5x5 neighborhood),
%   Gaussian blur (2 pixel),
%   Sharpening (radius 2, amount 1 unsharp mask),
%   Zooming in (14%),
%   Zooming out (14%).
rng('default');
trainDataNoise = gen(@(x) imnoise(x, 'gaussian'));
trainDataMedian = gen(@(x) medfilt2(x, [5 5], 'symmetric'));
trainDataBlur = gen(@(x) imgaussfilt(x, 2));
trainDataSharp = gen(@(x) imadjust(imsharpen(x, 'Radius',2, 'Amount',1)));
trainDataZoomIn = gen(@(x) imadjust(imresize(x(3:end-2,3:end-2),1.14)));
trainDataZoomOut = gen(@(x) imadjust(padarray(imresize(x, 0.86), [2 2], 1)));

% Preview changes.
figure, displayData(trainData(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-orig.png'));
figure, displayData(trainDataNoise(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-noise.png'));
figure, displayData(trainDataMedian(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-median.png'));
figure, displayData(trainDataBlur(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-blur.png'));
figure, displayData(trainDataSharp(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-sharp.png'));
figure, displayData(trainDataZoomIn(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-zoomin.png'));
figure, displayData(trainDataZoomOut(:,1:end-2), [32 32], 2, 5, 1, 40);
saveas(gcf, sprintf('newData/data-zoomout.png'));

beep on; beep;
save('extra.mat', 'trainDataNoise', 'trainDataMedian', 'trainDataBlur', ...
     'trainDataSharp', 'trainDataZoomIn', 'trainDataZoomOut');

%% Train SVMs

if ~exist('trainData', 'var'), load('train.mat', 'trainData'); end
if ~exist('trainDataNoise', 'var'), load('extra.mat', 'trainDataNoise'); end
if ~exist('trainDataMedian', 'var'), load('extra.mat', 'trainDataMedian'); end
if ~exist('trainDataBlur', 'var'), load('extra.mat', 'trainDataBlur'); end
if ~exist('trainDataSharp', 'var'), load('extra.mat', 'trainDataSharp'); end
if ~exist('trainDataZoomIn', 'var'), load('extra.mat', 'trainDataZoomIn'); end
if ~exist('trainDataZoomOut', 'var'), load('extra.mat', 'trainDataZoomOut'); end

% Prepare original and "extra" training data.
origX = trainData(:,1:end-2);
origY1 = trainData(:,end-1);
origY2 = trainData(:,end);

extraX = {[] trainDataNoise(:,1:end-2) trainDataMedian(:,1:end-2) ...
          trainDataBlur(:,1:end-2) trainDataSharp(:,1:end-2) ...
          trainDataZoomIn(:,1:end-2) trainDataZoomOut(:,1:end-2)};
extraY1 = {[] trainDataNoise(:,end-1) trainDataMedian(:,end-1) ...
           trainDataBlur(:,end-1) trainDataSharp(:,end-1) ...
           trainDataZoomIn(:,end-1) trainDataZoomOut(:,end-1)};
extraY2 = {[] trainDataNoise(:,end) trainDataMedian(:,end) ...
           trainDataBlur(:,end) trainDataSharp(:,end) ...
           trainDataZoomIn(:,end) trainDataZoomOut(:,end)};

% Selection methods:
%   1v1 voting scheme (break ties randomly),
%   1vAll highest score wins.
% Kernels:
%   Linear
%   Polynomial (order 3, 5, 7)
%   RBF
% Scale for kernels is 'auto' for everything for consistency.
types = {'1v1', '1vAll'};
funcs = {{'linear', 'auto'}, {'polynomial', 'auto', 3}, ...
         {'polynomial', 'auto', 5}, {'polynomial', 'auto', 9}, ...
         {'rbf', 'auto'}};
     
% Train models (note: takes a while)
rng('default');
letterModels = trainSvmModels(origX, origY2, extraX, extraY2, types, funcs);
personModels = trainSvmModels(origX, origY1, extraX, extraY1, types, funcs);

beep on; beep;
save('models.mat', 'letterModels', 'personModels');

%% Test and evaluate SVMs

if ~exist('trainData', 'var'), load('train.mat', 'trainData'); end
if ~exist('testData', 'var'), load('test.mat', 'testData'); end
if ~exist('letterModels', 'var'), load('models.mat', 'letterModels'); end
if ~exist('personModels', 'var'), load('models.mat', 'personModels'); end

% Load training/test data
trainX = trainData(:,1:end-2);
trainY = trainData(:,end-1:end);

testX = testData(:,1:end-2);
testY = testData(:,end-1:end);

% Calculate each model's performance.
rng('default');
letterEval = evalModels(letterModels, trainX, trainY(:,2), testX, testY(:,2));
personEval = evalModels(personModels, trainX, trainY(:,1), testX, testY(:,1));

beep on; beep;
save('eval.mat', 'letterEval', 'personEval');

%% Save some evaluation metrics
if ~exist('letterEval', 'var'), load('eval.mat', 'letterEval'); end
if ~exist('letterEval', 'var'), load('eval.mat', 'personEval'); end

savefile = @(name,x) dlmwrite(name, x, 'delimiter','\t');

% F-score/accuracy
out = cellfun(@(x) x.train.fscore, letterEval);
savefile('results/letter-train-fscore-1v1.txt', out(:,:,1));
savefile('results/letter-train-fscore-all.txt', out(:,:,2));

out = cellfun(@(x) x.train.accuracy, letterEval);
savefile('results/letter-train-accuracy-1v1.txt', out(:,:,1));
savefile('results/letter-train-accuracy-all.txt', out(:,:,2));

out = cellfun(@(x) x.test.fscore, letterEval);
savefile('results/letter-test-fscore-1v1.txt', out(:,:,1));
savefile('results/letter-test-fscore-all.txt', out(:,:,2));

out = cellfun(@(x) x.test.accuracy, letterEval);
savefile('results/letter-test-accuracy-1v1.txt', out(:,:,1));
savefile('results/letter-test-accuracy-all.txt', out(:,:,2));

out = cellfun(@(x) x.train.fscore, personEval);
savefile('results/person-train-fscore-1v1.txt', out(:,:,1));
savefile('results/person-train-fscore-all.txt', out(:,:,2));

out = cellfun(@(x) x.train.accuracy, personEval);
savefile('results/person-train-accuracy-1v1.txt', out(:,:,1));
savefile('results/person-train-accuracy-all.txt', out(:,:,2));

out = cellfun(@(x) x.test.fscore, personEval);
savefile('results/person-test-fscore-1v1.txt', out(:,:,1));
savefile('results/person-test-fscore-all.txt', out(:,:,2));

out = cellfun(@(x) x.test.accuracy, personEval);
savefile('results/person-test-accuracy-1v1.txt', out(:,:,1));
savefile('results/person-test-accuracy-all.txt', out(:,:,2));

% Confusion matrices
[depth, rows, cols] = size(letterEval);
for k=1:depth
    for i=1:rows
        for j=1:cols
            filename = sprintf('results/letter-train-confusion-%d-%d-%d.txt', k,i,j);
            savefile(filename, letterEval{k,i,j}.train.confusion);
            filename = sprintf('results/letter-test-confusion-%d-%d-%d.txt', k,i,j);
            savefile(filename, letterEval{k,i,j}.test.confusion);
            
            filename = sprintf('results/person-train-confusion-%d-%d-%d.txt', k,i,j);
            savefile(filename, personEval{k,i,j}.train.confusion);        
            filename = sprintf('results/person-test-confusion-%d-%d-%d.txt', k,i,j);
            savefile(filename, personEval{k,i,j}.test.confusion);
        end
    end
end

beep on; beep;
