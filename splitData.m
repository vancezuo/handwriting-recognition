function [ trainData, testData ] = splitData( data, groups, prop)
%SPLITDATA Splits data rows into training and testing sets (randomly)
%   Vance Zuo, STAT 365 Final Project
    
    n = size(data,1);
  
    if ~exist('prop', 'var')
        prop = [1 1];
    end    
    if ~exist('groups', 'var')
        groups = 1;
    end
    
    p = prop(1) / sum(prop);
    
    trainData = zeros(n*p, size(data,2));
    testData = zeros(n*(1-p), size(data,2));
    
    slices = [n*p/groups n*(1-p)/groups];

    for i=1:groups
        tr_i = 1+(i-1)*slices(1);
        te_i = 1+(i-1)*slices(2);
        
        total = sum(slices);
        total_tr = total*p;
        total_te = total - total_tr;
        tr_r = randsample(1:total, total_tr);
        te_r = setdiff(1:total, tr_r);
        tr_r = tr_r + (i-1)*total;
        te_r = te_r + (i-1)*total;
        
        trainData(tr_i:tr_i+total_tr-1,:) = data(tr_r,:);
        testData(te_i:te_i+total_te-1,:) = data(te_r,:);
    end

end

