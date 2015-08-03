function [ data ] = loadData( image, varargin )
% LOADDATA Loads image data as rows into a matrix.
%   Vance Zuo, STAT 365 Final Project

    % Parse arguments
    p = inputParser;
    p.FunctionName = 'loadData';

    addRequired(p, 'image');    
    addParameter(p, 'rows', 'interactive');
    addParameter(p, 'cols', 'interactive');
    addParameter(p, 'rotation', 0);
    addParameter(p, 'reference', 'interactive');
    addParameter(p, 'offset', [0 0]);
    addParameter(p, 'checktiles', false);
    addParameter(p, 'preview', false);
    
    parse(p, image, varargin{:});
    
    rows = p.Results.rows;
    cols = p.Results.cols;
    rotation = p.Results.rotation;
    tile = p.Results.reference;
    offset = p.Results.offset;
    checkTiles = p.Results.checktiles;
    preview = p.Results.preview;
    
    % Determine rows/columns
    if isInteractive(rows)
        rows = input('How many rows of data? ');
    end  
    
    if isInteractive(cols)
        cols = input('How many columns of data? ');
    end
    
    % Rotate image to align tiles with x/y axis
    if isInteractive(rotation)
        fprintf('Select a rotation angle... ');
        rotation = askRotation(image);        
        fprintf('%g\n', rotation);
    end    
    image = imrotate(image, rotation);
    
    % Get reference tile and offsets
    if isInteractive(tile)
        fprintf('Select a reference tile... ');
        tile = askTile(image);     
        fprintf('%s\n', sprintf('%d ', tile));
    end
    
    if isInteractive(offset)
        fprintf('Select tiles to determine width/height offset... ');
        offset = askOffset(image, tile);
        fprintf('%s\n', sprintf('%d ', offset));
    end
    
    % Extract data points
    tiles = generateTiles(tile, offset, rows, cols);
    width = tile(3);
    height = tile(4);
    
    if checkTiles
        fprintf('Confirm tiles are okay (dbl-click top left)... ');
        tiles = askCheckTiles(image, tiles);
        fprintf('done.\n');
    end
    
    if preview, figure, end
    
    data = zeros(rows*cols, height*width);
    for i=1:size(tiles,1)
        t = num2cell(tiles(i,:));
        [col, row, width, height] = t{:};
        crop = image(row:row+height-1,col:col+width-1);
        data(i,:) = crop(:);
        
        if preview
            subplot(rows, cols, i);
            imshow(crop);            
        end
    end
end

function bool = isInteractive(var)
    bool = strcmpi(var, 'interactive');
end

% Based on: http://stackoverflow.com/q/6549538
function rotation = askRotation(image)
    rotation = 0;
    
    f = figure();
    ax = axes('Parent',f);
    dispGridImage(image);
    uicontrol('Style','slider', 'Value',0, 'Min',-360, 'Max',360, ...
              'SliderStep',[1 10]./72000, 'Position',[150 10 300 20], ...
              'Parent',f, 'Callback',@sliderCallback)           
    txt = uicontrol('Style','text', 'Position',[290 30 30 20], ...
                    'String',num2str(rotation));

    waitfor(f);
    
    function sliderCallback(obj, eventdata)
        rotation = roundn(get(obj,'Value'), -2);
        set(txt, 'String', sprintf('%g', rotation));
        dispGridImage(imrotate(image, rotation));
    end

    % Based on: http://stackoverflow.com/q/4181946
    function dispGridImage(im)
        imshow(im, 'Parent',ax, 'InitialMagnification',100);
        
        hold on;
        
        M = size(im,1);
        N = size(im,2);
        incr = round(length(im) / 20);

        for k = 1:incr:M
            x = [1 N];
            y = [k k];
            plot(x,y,'Color','w','LineStyle','-');
            plot(x,y,'Color','k','LineStyle',':');
        end

        for k = 1:incr:N
            x = [k k];
            y = [1 M];
            plot(x,y,'Color','w','LineStyle','-');
            plot(x,y,'Color','k','LineStyle',':');
        end

        hold off
    end
end

function tile = askTile(image, initTile, constraintFcn)
    if ~exist('initTile', 'var')
        initTile = [];
    end
    
    if ~exist('constraintFcn', 'var')
        xlim = [1 size(image,2)];
        ylim = [1 size(image,1)];
        constraintFcn = makeConstrainToRectFcn('imrect', xlim, ylim);
    end

    f = figure(); 
    imshow(image, 'InitialMagnification',100);
    txt = uicontrol('Style','text', 'Position',[200 30 150 20]);
    
    h = imrect(gca, initTile, 'PositionConstraintFcn',...
               @(x) round(constraintFcn(x)));
    h.Deletable = false;
    addNewPositionCallback(h, @posCallback);
    
    wait(h);
    tile = h.getPosition();    
    
    close(f);
    
    function posCallback(obj, eventdata)
        pos = num2cell(h.getPosition());        
        [x, y, width, height] = pos{:};        
        set(txt, 'String', sprintf('%d %d %d %d', x, y, width, height));
    end
end

function offset = askOffset(image, tile)
    % Get height offset
    xlim = [tile(1) tile(1)+tile(3)];
    ylim = [1 size(image,1)];
    fcn = makeConstrainToRectFcn('imrect', xlim, ylim);
    newTile = askTile(image, tile, fcn);
    
    offset(1) = newTile(2) - tile(2);
    
    % Get width offset
    xlim = [1 size(image,2)];
    ylim = [tile(2) tile(2)+tile(4)];
    fcn = makeConstrainToRectFcn('imrect', xlim, ylim);
    newTile = askTile(image, tile, fcn);
    
    offset(2) = newTile(1) - tile(1);
end

function tiles = generateTiles(tile, offset, rows, cols)
    tiles = zeros(rows*cols, 4);
    
    tile(2) = tile(2) - offset(1); % prepare row
    tile(1) = tile(1) - offset(2); % prepare col
    for i=1:rows
        tile(2) = tile(2) + offset(1); % row update
        for j=1:cols
            tile(1) = tile(1) + offset(2); % col update
            tiles(cols*(i-1)+j,:) = tile(:);
        end
        tile(1) = tile(1) - cols*offset(2);
    end
end

function tiles = askCheckTiles(image, tiles)
    f = figure();    
    imshow(image, 'InitialMagnification',100);
    
    xlim = [1 size(image,2)];
    ylim = [1 size(image,1)];
    constraintFcn = makeConstrainToRectFcn('imrect', xlim, ylim);
    
    h = cell(size(tiles,1), 1);
    for i=1:size(tiles,1)
        h{i} = imrect(gca, tiles(i,:),  'PositionConstraintFcn',...
                      @(x) round(constraintFcn(x)));
        h{i}.Deletable = false;
        setResizable(h{i}, false);
    end
    
    wait(h{1});
    
    for i=1:size(tiles,1)
        tiles(i,:) = h{i}.getPosition(); 
    end
    
    close(f);
end
