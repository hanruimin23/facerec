classdef PCA < handle

    properties (SetAccess = immutable)
        DataMu
        PCs
        Variances
    end

    properties (Dependent)
        Energy
        NumberOfPCs
        WhitenedPCs
    end

    methods

        function obj = PCA(data)
            obj.DataMu = mean(data);
            [obj.PCs, ~, obj.Variances] = princomp(data, 'econ');
        end

        function out = get.Energy(obj)
            out = cumsum(obj.Variances) / sum(obj.Variances);
        end

        function out = get.NumberOfPCs(obj)
            out = length(obj.Variances);
        end

        function out = get.WhitenedPCs(obj)
            out = bsxfun(@times, obj.PCs, (obj.Variances .^ -0.5)');
        end

        function out = getSufficientNPCs(obj, e)
            assert(e > 0 && e <= 1, '''e'' must be in (0, 1] interval.');

            energy = obj.Energy;
            for out = 1:obj.NumberOfPCs
                if energy(out) >= e
                    break;
                end
            end
        end

        function fun = getProjFun(obj, nPCs, whitened)
            assert(nPCs > 0 && nPCs <= obj.NumberOfPCs, sprintf( ...
                '''nPCs'' must be in (0, %d] interval', obj.NumberOfPCs));

            if nargin < 3 || ~whitened
                T = obj.PCs(:, 1:nPCs);
            else
                T = obj.WhitenedPCs(:, 1:nPCs);
            end

            fun = @(u) bsxfun(@minus, u, obj.DataMu) * T;
        end

    end

end
