function [ models ] = trainSvmModels( origX, origY, extraX, extraY, ...
                                      types, funcs )
% TRAINMULTISVMMODEL Trains many (multi-class) SVM models on many data
%   Vance Zuo, STAT 365 Final Project

    models = cell(size(extraX,2), size(funcs,2), size(types,2));
    
    for k=1:size(extraX,2)
        X = vertcat(origX, extraX{k});
        y = vertcat(origY, extraY{k});

        for i=1:size(funcs,2)
            func = funcs{i};

            name = func{1};
            scale = func{2};
            if strcmpi(name, 'polynomial')
                order = func{3};
                f = @(X,y) compact(fitcsvm(X, y, 'KernelFunction', name, ...
                                   'KernelScale',scale , 'Standardize',true, ...
                                   'PolynomialOrder',order));
            else
                f = @(X,y) compact(fitcsvm(X, y, 'KernelFunction', name, ...
                                   'KernelScale',scale , 'Standardize',true));
            end

            for j=1:size(types,2)
                type = types{j};

                models{k,i,j} = trainSvmModel(X, y, type, f);
            end
            models
        end

    end

end

