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

        function loadPairs(obj, posPairs, negPairs, shuffle)
            nPosPairs = size(posPairs{1}, 1);
            nNegPairs = size(negPairs{1}, 1);
            nPairs = nPosPairs + nNegPairs;

            X = cell(nPairs, 1);
            Y = cell(nPairs, 1);

            for idx = 1:nPosPairs
                X{idx} = obj.loadSample(posPairs{1}{idx}, posPairs{2}(idx));
                Y{idx} = obj.loadSample(posPairs{1}{idx}, posPairs{3}(idx));
            end

            for idx = 1:nNegPairs
                X{nPosPairs + idx} = obj.loadSample(negPairs{1}{idx}, ...
                    negPairs{2}(idx));
                Y{nPosPairs + idx} = obj.loadSample(negPairs{3}{idx}, ...
                    negPairs{4}(idx));
            end

            labels = num2cell([true(nPosPairs, 1); false(nNegPairs, 1)]);
            fold = num2cell((obj.NumberOfFolds + 1) * ones(nPairs, 1));
            pairs = [X, Y, labels, fold];

            if nargin < 4 || shuffle
                pairs = pairs(randperm(nPairs), :);
            end

            obj.pairs = [obj.pairs; pairs];
        end

        function [training, val, test] = getFold(obj, fold, trainToValRatio)
            assert(fold >= 1 && fold <= obj.NumberOfFolds, sprintf( ...
                'There''s no fold ''%d''.', fold));

            if nargin < 3
                trainToValRatio = 1;
            end

            assert(trainToValRatio > 0 && trainToValRatio <= 1, ...
                '''trainToValRatio'' must be in (0, 1] interval.');

            mask = cell2mat(obj.pairs(:, end)) == fold;

            training = obj.samplesData.values(obj.pairs(~mask, 1:2));
            training = [training, obj.pairs(~mask, 3)];
            nTraining = ceil(trainToValRatio * size(training, 1));
            val = training(nTraining + 1:end, :);
            training = training(1:nTraining, :);

            test = obj.samplesData.values(obj.pairs(mask, 1:2));
            test = [test, obj.pairs(mask, 3)];
        end

        function [testStats, valStats, trainingStats] = evalMatcher(obj, ...
                fold, scoreFun, trainToValRatio)
            if nargin < 4
                trainToValRatio = 1;
            end

            [training, val, test] = obj.getFold(fold, trainToValRatio);
            scores = utils.computeScores(test(:, 1), test(:, 2), scoreFun);
            testStats = utils.Stats(scores, cell2mat(test(:, 3)));
            if nargout >= 2
                valStats = [];
                if ~isempty(val)
                    scores = utils.computeScores(val(:, 1), val(:, 2), ...
                        scoreFun);
                    valStats = utils.Stats(scores, cell2mat(val(:, 3)));
                end
            end
            if nargout == 3
                scores = utils.computeScores(training(:, 1), training(:, 2), ...
                    scoreFun);
                trainingStats = utils.Stats(scores, cell2mat(training(:, 3)));
            end
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
