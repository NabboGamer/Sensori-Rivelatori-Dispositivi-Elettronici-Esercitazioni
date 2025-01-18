% Questo script implementa l'estensione del modello terminale
% nel modo tickness a una coppia di ceramiche piezoelettriche

addpath('../utility/');
evalin('base', 'clear'), close all; clc;

[areaFaccia, l, rho, ~, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

% Impedenza acustica della ceramica in direzione z
ZoD = areaFaccia * v * rho;
        
% Impedenza acustica del carico
Zel = 1E+06; %1MOhm

% Impedenza acustica specifica del mezzo
z1 = specificAcousticImpedancePicker(1);
z2 = specificAcousticImpedancePicker(2);

% Impedenza acustica del mezzo
Z1 = areaFaccia * z1;
Z2 = areaFaccia * z2;
 
% Matrici A(3x3), B(2x2) e G (3x3).
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_Z1 = calcolaMatriceB(A, Z2);
B_Z2 = calcolaMatriceB(A, Z1);

% Prelevo il numero di coppie di ceramiche desiderate
numberOfCeramicPairs = numberOfCeramicPairsPicker();

% Calcolo la frazione dello spessore e della capacità
% statica che deve avere ciascuna coppia di ceramiche
new_l = l / (2 ^ numberOfCeramicPairs);
new_C0 = (2 ^ numberOfCeramicPairs) * C0;

%Rifaccio i calcoli per la coppia di ceramiche
%Matrici A(3x3), B(2x2) e G(3x3)
A_couple = calcolaMatriceA(ZoD, omega, v, new_l, h33, new_C0);

%Accoppio le ceramiche
G = calcolaMatriceG(A_couple, A_couple);
G_multiple = G;

if (numberOfCeramicPairs > 1)
    for n = 1 : (numberOfCeramicPairs-1)
        G_multiple = calcolaMatriceG(G_multiple, G_multiple);
    end
    G = G_multiple;
end

B_couple_Z1 = calcolaMatriceB(G, Z2);
B_couple_Z2 = calcolaMatriceB(G, Z1);

% Calcolo l'impedenza elettrica in ingresso
[Zin_Z1, FTT_Z1, FTR_Z1] = calcolaFunzioniDiTrasferimento(B_Z1, Z1, Zel);
[Zin_Z2, FTT_Z2, FTR_Z2] = calcolaFunzioniDiTrasferimento(B_Z2, Z2, Zel);

[Zin_couple_Z1, FTT_Z1_couple, FTR_Z1_couple] = calcolaFunzioniDiTrasferimento(B_couple_Z1, Z1, Zel);
[Zin_couple_Z2, FTT_Z2_couple, FTR_Z2_couple] = calcolaFunzioniDiTrasferimento(B_couple_Z2, Z2, Zel);

if(Z1 == Z2)
    var_z = "Zi";
    var_FTT = "TTF";
    %var_FTT_i = "TTF_i";
    var_FTR = "RTF";
else
    var_z = "Zi side 1";
    var_FTT = "TTF side 1";
    %var_FTT_i = "TTF_i side 1";
    var_FTR = "RTF side 1";
end

figure(1)
stampaGraficiCoppia(f, Z1, Z2, Zin_couple_Z1, Zin_Z1, var_z, 1);

figure(2)
stampaGraficiCoppia(f, Z1, Z2, FTT_Z1_couple, FTT_Z1, var_FTT, 1);

% figure(3)
% stampaGraficiCoppia(f, Z1, Z2, FTT_Z1_i_couple, FTT_Z1_i, var_FTT_i, 1);

figure(4)
stampaGraficiCoppia(f, Z1, Z2, FTR_Z1_couple, FTR_Z1, var_FTR, 1);

if(Z1 ~= Z2)
    var_z = "Zi side 2";
    var_FTT = "TTF side 2";
    %var_FTT_i = "TTF_i side 2";
    var_FTR = "RTF side 2";

    figure(1)
    stampaGraficiCoppia(f, Z1, Z2, Zin_couple_Z2, Zin_Z2, var_z, 2);
    
    figure(2)
    stampaGraficiCoppia(f, Z1, Z2, FTT_Z2_couple, FTT_Z2, var_FTT, 2);
    
%     figure(3)
%     stampaGraficiCoppia(f, Z1, Z2, FTT_Z2_i_couple, FTT_Z2_i, var_FTT_i, 2);
    
    figure(4)
    stampaGraficiCoppia(f, Z1, Z2, FTR_Z2_couple, FTR_Z2, var_FTR, 2);
end
