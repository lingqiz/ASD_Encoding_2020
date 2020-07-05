function prior = priorHandle(weight)
% Return the function handle to the default prior: 2 - scale * |sin(theta)|.
stepSize = 0.01; stmSpc = 0 : stepSize : 2 * pi;
priorUnm = 1 - abs(sin(stmSpc));
nrmConst = 1.0 / trapz(stmSpc, priorUnm);

naturalPrior = @(support) (1 - abs(sin(support))) * nrmConst;
uniformPrior = 1 / (2 * pi);

prior = @(support) naturalPrior(support) * weight + uniformPrior * (1 - weight);
end