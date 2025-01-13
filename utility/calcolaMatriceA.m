function A = calcolaMatriceA(ZoD, omega, v, l, h33, C0)
    %CALCOLAMATRICEA permette di calcolare la matrice A per la ceramica

    k = omega ./ v;

    A11 = ZoD ./ ( 1i .* tan(k .* l) );

    A12 = ZoD ./ ( 1i .* sin(k .* l) );

    A13 = h33 ./ ( 1i .* omega );

    A33 = 1 ./ ( 1i .* omega .* C0) ;
    
    A = {A11; A12; A13; A33};

end

