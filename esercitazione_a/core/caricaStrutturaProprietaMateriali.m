function strutturaProprietaMateriali = caricaStrutturaProprietaMateriali()
%CARICASTRUTTURAPROPRIETAMATERIALI carica in memoria una struct MATLAB con proprietà utili di una serie di materiali impiegati nella produzione di strati puramente meccanici

strutturaProprietaMateriali={};

strutturaProprietaMateriali{1,1} = "Acciaio inossidabile 347";
strutturaProprietaMateriali{1,2} = [5.9e+03; 7.89e+03; 45.7e+06];

strutturaProprietaMateriali{2,1} = "Alluminio 6262-T9";
strutturaProprietaMateriali{2,2} = [6.38e+03; 2.73e+03; 17.41e+06];

strutturaProprietaMateriali{3,1} = "Ferro";
strutturaProprietaMateriali{3,2} = [5.9e+03; 7.69e+03; 46.4e+06];

strutturaProprietaMateriali{4,1} = "Titanio";
strutturaProprietaMateriali{4,2} = [6.1e+03; 4.48e+03; 27.3e+06];

strutturaProprietaMateriali{5,1} = "Tungsteno";
strutturaProprietaMateriali{5,2} = [5.2e+03; 19.4e+03; 101.0e+06];

% Converti in containers.Map per permettere l'accesso tramite chiave
keys = string(strutturaProprietaMateriali(:, 1));
values = strutturaProprietaMateriali(:, 2);
strutturaProprietaMateriali = containers.Map(keys, values);

end