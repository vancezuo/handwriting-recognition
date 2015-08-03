function [ newData ] = genData( data, dim, func )
%GENDATA Generates new data by applying a function on original data.
%   Vance Zuo, STAT 365 Final Project
    
    newData = zeros(size(data));
    for i=1:size(data,1)
        newImage = func(reshape(data(i,1:end-2), dim));
        newData(i,1:end-2) = newImage(:);
        newData(i,end-1:end) = data(i,end-1:end);
    end

end

