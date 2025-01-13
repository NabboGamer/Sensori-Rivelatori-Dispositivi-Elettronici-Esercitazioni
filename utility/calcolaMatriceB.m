function B = calcolaMatriceB(A, Z)
    %CALCOLAMATRICEB permette di calcolare la matrice B per la ceramica
    
    B11 = A{1} - ( (A{2} .^ 2) ./ (Z + A{1}) );

    B12 = A{3} - ( (A{2} .* A{3}) ./ (Z + A{1}) ) ;
     
    B22 = A{4} - ( (A{3} .^ 2) ./ (Z + A{1}) );
    
    B = {B11, B12, B22};
    
end

