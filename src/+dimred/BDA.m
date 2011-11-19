classdef BDA < handle

    properties (Dependent)
        MaxDim
    end

    properties (SetAccess = immutable)
        Transformation
    end

    methods

        function obj = BDA(X, Y, l)
            D = X - Y;
            D = bsxfun(@minus, D, mean(D(l, :)));
            Sp = D(l, :)' * D(l, :);
            Sn = D(~l, :)' * D(~l, :);

            [eigvecs, eigvals] = eig(pinv(Sp) * Sn);
            [eigvals, eigvalsIdx] = sort(diag(eigvals), 'descend');
            obj.Transformation = eigvecs(:, eigvalsIdx(eigvals > eps));
        end

        function out = get.MaxDim(obj)
            out = size(obj.Transformation, 2);
        end

        function fun = getProjFun(obj, dim)
            assert(dim > 0 && dim <= obj.MaxDim, sprintf(['''dim'' must ', ...
                'be in (0, %d] interval.'], obj.MaxDim));

            fun = @(u) u * obj.Transformation(:, 1:dim);
        end

    end

end
