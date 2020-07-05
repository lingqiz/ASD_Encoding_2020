function density = vonmpdf(support, mu, kappa)
%VONMPDF von Mises probability density function (pdf).
%   density = vonmpdf(support, mu, kappa) calculates the probability density function 
%   of von Mises distribution over SUPPORT with mean MU and concentration KAPPA.

density = exp(kappa * cos(support - mu)) / (2 * pi * besseli(0, kappa));

end

