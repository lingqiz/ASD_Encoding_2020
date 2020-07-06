function [paras, l1, l2] = expectedBias(average, spread, range, showPlot, lineColor)

objective = @(para) lossFunc(para(1), para(2));
paras = fmincon(objective, [1, 1], [], [], [], [], [0, 0], [1, +Inf]);

if showPlot
    hold on; grid on;
    l1 = plot(range, average, 'LineWidth', 2, 'Color', lineColor);
    l2 = plot(range, predBias(paras(1), paras(2)), '--', 'LineWidth', 2, 'Color', zeros(1, 3));
    xlim([0, 2 * pi]); ylim([-pi/3, pi/3]);
    title('Fit to Bias')
end

    function bias = predBias(scale, noise)
        domain = 0 : 0.01 : 2 * pi;
        prior  = priorHandle(scale);
        fisher = prior(domain) * noise;
        
        % Cramer-Rao Bound
        % 1 + b'(x) = sqrt(fisher) * std(x)
        d_bias = interp1(domain, fisher, range) .* sqrt(abs(spread)) - 1;
        bias   = cumtrapz(range, d_bias);
    end

    function loss = lossFunc(scale, noise)
        loss = norm(predBias(scale, noise) - average);
    end
end