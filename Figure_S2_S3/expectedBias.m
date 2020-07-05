function [paras, l1, l2, R_sqr] = expectedBias(average, spread, range, showPlot, lineColor)

objective = @(para) lossFunc(para(1), para(2));
options = optimoptions('fmincon','Display', 'off');
paras = fmincon(objective, [1, 1], [], [], [], [], [0, 0], [1, +Inf], [], options);


if showPlot
    hold on; grid on;
    l1 = plot(range, average, 'LineWidth', 2, 'Color', lineColor);
    pred = predBias(paras(1), paras(2));
    l2 = plot(range, pred, '--', 'LineWidth', 2, 'Color', zeros(1, 3));
    
    % r-squared value
    
    S_total = sum((average - mean(average)) .^ 2);    
    S_res   = sum((average - pred) .^ 2);
    R_sqr   = 1 - S_res / S_total;
        
    legend(l2, num2str(R_sqr, 2));
    
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