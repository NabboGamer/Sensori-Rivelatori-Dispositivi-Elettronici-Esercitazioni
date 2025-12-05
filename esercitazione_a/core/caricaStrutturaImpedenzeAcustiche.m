function strutturaImpedenzeAcustiche = caricaStrutturaImpedenzeAcustiche()
%CARICASTRUTTURAIMPEDENZEACUSTICHE carica in memoria una struct MATLAB con valori delle impedenze acustiche dei mezzi standard

strutturaImpedenzeAcustiche={};

strutturaImpedenzeAcustiche{1,1} = "Acqua (20°C)";
strutturaImpedenzeAcustiche{1,2} = 1479036;

strutturaImpedenzeAcustiche{2,1} = "Aria (20°C)";
strutturaImpedenzeAcustiche{2,2} = 414.5;

strutturaImpedenzeAcustiche{3,1} = "Alcol Etilico";
strutturaImpedenzeAcustiche{3,2} = 972842;

strutturaImpedenzeAcustiche{4,1} = "Gel (Ultrasonico)";
strutturaImpedenzeAcustiche{4,2} = 1500000;

% Converti in containers.Map per permettere l'accesso tramite chiave
% Converti in containers.Map per permettere l'accesso tramite chiave
keys = string(strutturaImpedenzeAcustiche(:, 1));
values = strutturaImpedenzeAcustiche(:, 2);
strutturaImpedenzeAcustiche = containers.Map(keys, values);

end