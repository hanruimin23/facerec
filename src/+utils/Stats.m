classdef Stats

    properties (SetAccess = immutable)
        Scores
        Labels
        Thresholds
        HitRates
        FPRates
        TPRates
    end

    properties (Dependent)
        IsFromMultipleFolds
    end

    methods

        function obj = Stats(scores, labels)
            assert(~isempty(scores), 'Can''t compute stats without scores.');

            [nSamples, nFolds] = size(scores);

            nFp = zeros(nSamples, nFolds);
            nFn = zeros(nSamples, nFolds);
            threshs = sort(scores, 1);

            for idx1 = 1:nFolds
                nPosSamples(idx1) = length(find(labels(:, idx1)));
                for idx2 = 1:nSamples
                    nFp(idx2, idx1) = length(find(scores(:, idx1) >= ...
                        threshs(idx2, idx1) & ~labels(:, idx1)));
                    nFn(idx2, idx1) = length(find(scores(:, idx1) < ...
                        threshs(idx2, idx1) & labels(:, idx1)));
                end
            end

            obj.Scores = scores;
            obj.Labels = labels;
            obj.Thresholds = [];
            if nFolds == 1
                obj.Thresholds = threshs;
            end

            obj.HitRates = 1 - mean((nFp + nFn) / nSamples, 2);
            obj.FPRates = mean(bsxfun(@rdivide, nFp, nSamples - ...
                nPosSamples), 2);
            obj.TPRates = 1 - mean(bsxfun(@rdivide, nFn, nPosSamples), 2);
        end

        function out = get.IsFromMultipleFolds(obj)
            out = isempty(obj.Thresholds);
        end

        function plotROC(obj, includeRefPoints, plotTitle, varargin)
            if nargin < 3 || isempty(plotTitle)
                plotTitle = 'Receiver-Operating Curve';
                if obj.IsFromMultipleFolds
                    plotTitle = ['Mean ', plotTitle];
                end
            end
            if isempty(varargin)
                varargin = {'k'};
            end

            plot(obj.FPRates, obj.TPRates, varargin{:});
            xlabel('False Positive');
            ylabel('True Positive');
            title(plotTitle, 'Interpreter', 'none', 'FontWeight', 'bold', ...
                'FontSize', 12);
            grid on;

            if nargin < 2 || includeRefPoints
                refPointsPlotOpts = {'o', 'LineWidth', 2, 'MarkerEdgeColor', ...
                    'k', 'MarkerSize', 6};
                [~, fpr, tpr, ~] = obj.getBestHR;
                hold on;
                plot(fpr, tpr, refPointsPlotOpts{:}, 'MarkerFaceColor', 'g');
                hr = obj.getEqualErrorHR;
                plot(1 - hr, hr, refPointsPlotOpts{:}, 'MarkerFaceColor', 'b');
                legend('ROC', 'Biggest HR Point', 'Equal Error Point', ...
                    'Location', 'SouthEast');
                hold off;
            end
        end

        function area = getROCArea(obj, fpr)
            if nargin < 2
                fpr = 1;
            end

            fprMask = obj.FPRates <= fpr;
            area = 0;
            if length(find(fprMask)) > 1
                area = abs(trapz(obj.FPRates(fprMask), obj.TPRates(fprMask)));
            end
        end

        function [hr, tpr, thresh] = getRatesAtFPR(obj, fpr)
            [~, idx] = min(abs(fpr - obj.FPRates));
            hr = obj.HitRates(idx);
            tpr = obj.TPRates(idx);
            thresh = NaN;
            if ~obj.IsFromMultipleFolds
                thresh = obj.Thresholds(idx);
            end
        end

        function [hr, fpr, tpr] = getRatesAtThresh(obj, thresh)
            assert(~obj.IsFromMultipleFolds, ['This is an averaged ', ...
                'version of various folds stats so that there''s no ', ...
                'mapping between thresholds and rates.']);

            [~, idx] = min(abs(thresh - obj.Thresholds));
            hr = obj.HitRates(idx);
            fpr = obj.FPRates(idx);
            tpr = obj.TPRates(idx);
        end

        function [hr, fpr, tpr, thresh] = getBestHR(obj)
            [hr, idx] = max(obj.HitRates);
            fpr = obj.FPRates(idx);
            tpr = obj.TPRates(idx);
            thresh = NaN;
            if ~obj.IsFromMultipleFolds
                thresh = obj.Thresholds(idx);
            end
        end

        function [hr, thresh] = getEqualErrorHR(obj)
            [~, idx] = min(abs(1 - obj.TPRates - obj.FPRates));
            hr = obj.HitRates(idx);
            thresh = NaN;
            if ~obj.IsFromMultipleFolds
                thresh = obj.Thresholds(idx);
            end
        end

        function summarize(obj, showPlot)
            fprintf('Stats summary:\n');
            fprintf('\tIs from multiple folds? %d\n', obj.IsFromMultipleFolds);
            [hr, fpr, tpr, thresh] = obj.getBestHR;
            fprintf(['\tBiggest HR Point: hr=%.6f, fpr=%.6f, tpr=%.6f, ', ...
                'thresh=%.6f\n'], hr, fpr, tpr, thresh);
            [hr, thresh] = obj.getEqualErrorHR;
            fprintf(['\tEqual Error Point: tpr=%.6f, eer=%.6f, ', ...
                'thresh=%.6f\n'], hr, 1 - hr, thresh);
            [hr, tpr, thresh] = obj.getRatesAtFPR(0.05);
            fprintf('\tRates at fpr=5%%: hr=%.6f, tpr=%.6f, thresh=%.6f\n', ...
                hr, tpr, thresh);
            fprintf('\tROC Area: %.6f\n', obj.getROCArea);
            fprintf('\tROC Area up to fpr=5%%: %.6f\n', obj.getROCArea(0.05));
            if nargin > 1 && showPlot
                obj.plotROC
            end
        end

    end

end
