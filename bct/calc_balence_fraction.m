function VAL = calc_balence_fraction(VAL)

n_triangles = sum(VAL,2);
VAL = 100*bsxfun(@rdivide, VAL, n_triangles);

