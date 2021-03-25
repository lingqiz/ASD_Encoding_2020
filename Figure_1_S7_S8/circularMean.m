function estimate = circularMean(support, postMass, varargin)
%CIRCULARMEAN Helper function for calculating the mean of a distribution
%defined on a circular space.

p = inputParser;
p.addParameter('Complex', false, @(x) isa(x, 'logical'));
parse(p, varargin{:});

if(p.Results.Complex)
    % Circular mean with complex number
    vecAvg = sum(postMass .* exp(support * 1i));
    estimate = atan(imag(vecAvg)/real(vecAvg));
    
    if (real(vecAvg) < 0)
        estimate = estimate + pi;
    elseif (real(vecAvg) > 0 && imag(vecAvg) > 0)
        estimate = estimate + 2 * pi;
    end
    
else
    % Circular mean with trigonometric
    estimateSin = sum(postMass .* sin(support));
    estimateCos = sum(postMass .* cos(support));
    estimate = atan(estimateSin / estimateCos);

    if (estimateCos < 0)
        estimate = estimate + pi;
    elseif (estimateCos > 0 && estimate < 0)
        estimate = estimate + 2 * pi;
    end
end

end