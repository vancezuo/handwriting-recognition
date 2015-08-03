function [ p, z, se ] = proptest( p1, n1, p2, n2 )
%PROPTEST Does a proportion z-test.
%   Vance Zuo, STAT 365 Final Project

    phat = (p1*n1 + p2*n2) / (n1 + n2);
    
    se = sqrt(phat*(1-phat)*(1/n1 + 1/n2));
    z = (p1 - p2) / se;
    p = 2*(normcdf(-abs(z)));

end

