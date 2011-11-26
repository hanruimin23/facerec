classdef PairsDataset < matlab.mixin.Copyable

    properties (Access = private)
        datasetPath
        featFun
        samplesFmt
        samplesData
        pairs
    end

    properties (Dependent)
        NumberOfFolds
    end

    methods (Access = private)

        function key = loadSample(obj, name, id)
            key = sprintf('%s_%04d', name, id);
            % a dictionary is used to avoid storing repeated samples
            if ~obj.samplesData.isKey(key)
                path = sprintf('%s/%s/%s.%s', obj.datasetPath, name, key, ...
                    obj.samplesFmt);
                obj.samplesData(key) = obj.featFun(imread(path));
            end
        end

    end

    methods

        function obj = PairsDataset(datasetPath, featFun, samplesFmt)
            obj.datasetPath = datasetPath;
            obj.featFun = featFun;
            obj.samplesFmt = samplesFmt;
            obj.samplesData = containers.Map;
            obj.pairs = {};
        end

        function out = get.NumberOfFolds(obj)
            out = 0;
            if ~isempty(obj.pairs)
                out = length(unique(cell2mat(obj.pairs(:, end))));
            end
        end

        function loadPairs(obj, posPairs, negPairs, shuffle, hProgressBar)
            if nargin < 5
                hProgressBar = [];
            end

            nPosPairs = size(posPairs{1}, 1);
            nNegPairs = size(negPairs{1}, 1);
            nPairs = nPosPairs + nNegPairs;

            X = cell(nPairs, 1);
            Y = cell(nPairs, 1);

            for idx = 1:nPosPairs
                X{idx} = obj.loadSample(posPairs{1}{idx}, posPairs{2}(idx));
                Y{idx} = obj.loadSample(posPairs{1}{idx}, posPairs{3}(idx));
                if ~isempty(hProgressBar)
                    progress = idx / nPairs;
                    waitbar(progress, hProgressBar, sprintf('%.2f%%', ...
                        progress * 100));
                end
            end

            for idx = 1:nNegPairs
                X{nPosPairs + idx} = obj.loadSample(negPairs{1}{idx}, ...
                    negPairs{2}(idx));
                Y{nPosPairs + idx} = obj.loadSample(negPairs{3}{idx}, ...
                    negPairs{4}(idx));
                if ~isempty(hProgressBar)
                    progress = (nPosPairs + idx) / nPairs;
                    waitbar(progress, hProgressBar, sprintf('%.2f%%', ...
                        progress * 100));
                end
            end

            labels = num2cell([true(nPosPairs, 1); false(nNegPairs, 1)]);
            fold = num2cell((obj.NumberOfFolds + 1) * ones(nPairs, 1));
            pairs = [X, Y, labels, fold];

            if nargin < 4 || shuffle
                pairs = pairs(randperm(nPairs), :);
            end

            obj.pairs = [obj.pairs; pairs];
        end

        function valFolds = chooseValFolds(obj, testFold, nValFolds)
            assert(testFold >= 1 && testFold <= obj.NumberOfFolds, sprintf( ...
                'There''s no fold ''%d''.', testFold));
            assert(nValFolds >= 0 && nValFolds < obj.NumberOfFolds - 1, ...
                sprintf('''nValFolds'' must be in [0, %d) interval.', ...
                obj.NumberOfFolds - 1));

            valFolds = datasample(setdiff(1:obj.NumberOfFolds, testFold), ...
                nValFolds, 'Replace', false);
        end

        function [training, val, test] = getFold(obj, testFold, valFolds)
            assert(testFold >= 1 && testFold <= obj.NumberOfFolds, sprintf( ...
                'There''s no fold ''%d''.', testFold));

            if nargin < 3
                valFolds = [];
            end

            assert(~ismember(testFold, valFolds), ['The test fold can''t ', ...
                'be used for validation.']);

            folds = cell2mat(obj.pairs(:, end));
            valMask = any(cell2mat(arrayfun(@(f) folds == f, valFolds, ...
                'UniformOutput', false)), 2);
            testMask = folds == testFold;
            if isempty(valMask)
                trainingMask = ~testMask;
            else
                trainingMask = ~(valMask | testMask);
            end

            training = obj.samplesData.values(obj.pairs(trainingMask, 1:2));
            training = [training, obj.pairs(trainingMask, 3)];

            val = obj.samplesData.values(obj.pairs(valMask, 1:2));
            val = [val, obj.pairs(valMask, 3)];

            test = obj.samplesData.values(obj.pairs(testMask, 1:2));
            test = [test, obj.pairs(testMask, 3)];
        end

        function newObj = apply(obj, fun, newCopy)
            newObj = obj;
            if nargin < 3 || newCopy
                newObj = obj.copy;
            end

            samplesData = newObj.samplesData;
            newObj.samplesData = containers.Map;
            for key = samplesData.keys
                newObj.samplesData(key{:}) = fun(samplesData(key{:}));
            end
        end

    end

end
