function displayData( data, dim, rows, cols, start, step )
% DISPLAYDATA Displays image data (rows of matrix) in tiles.
%   Vance Zuo, STAT 365 Final Project

    if ~exist('step', 'var')
        step = 1;
    end 
    if ~exist('start', 'var')
        start = 1;
    end    
    if ~exist('cols', 'var')
        cols = 7;
    end
    if ~exist('rows', 'var')
        rows = 10;
    end
    n = rows*cols;

    for i=start:start+n-1
        ind = start+(i-start)*step;
        im = data(ind,:);
        im = im ./ max(im(:)); % normalize
        
        subplot(rows, cols, 1+mod(i-1, rows*cols));
        imshow(reshape(im, dim));
        
        axis on;
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);        
    end
end

