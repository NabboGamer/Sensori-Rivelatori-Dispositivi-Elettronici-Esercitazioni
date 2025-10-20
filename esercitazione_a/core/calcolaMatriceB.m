function B = calcolaMatriceB(A, Z)
    %CALCOLAMATRICEB permette di calcolare la matrice B per la ceramica
    
    B11 = A{1,1} - ( (A{1,2} .^ 2) ./ (Z + A{1,1}) );

    B12 = A{1,3} - ( (A{1,2} .* A{1,3}) ./ (Z + A{1,1}) ) ;

    B21 = B12;
     
    B22 = A{3,3} - ( (A{1,3} .^ 2) ./ (Z + A{1,1}) );
    
    B = {B11, B12;...
         B21, B22};

end