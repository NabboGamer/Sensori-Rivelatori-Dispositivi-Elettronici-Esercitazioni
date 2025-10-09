% Questo script implementa l'estensione del modello terminale
% nel modo tickness a una coppia di ceramiche piezoelettriche.
% Rispetto allo script modelloTerminaleCoppiaCeramichePiezoThickness qui
% non viene permessa la selezione all'utente dei mezzi di contatto con i 
% due lati della ceramica di modo da fare un confronto con i mezzi 
% standard ovvero ARIA-ARIA e ACQUA-ACQUA.

addpath('../utility/');
evalin('base', 'clear'), clc;

[areaFaccia, l, rho, ~, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

% Impedenza acustica della ceramica in direzione z
ZoD = areaFaccia * v * rho;
        
% Impedenza acustica del carico
Zel = 1E+06; %1MOhm

%% ARIA-ARIA
% Impedenza acustica specifica del mezzo
z1 = 414.5; % Rayl(Kg s^-1 m^-2) ARIA
z2 = 414.5; % Rayl(Kg s^-1 m^-2) ARIA

% Impedenza acustica del mezzo
Z1 = areaFaccia * z1;
Z2 = areaFaccia * z2;
 
% Matrici A(3x3), B(2x2) e G(3x3)
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_side1 = calcolaMatriceB(A, Z2); % la porta(o lato) 1 "vede" il carico Z2, B descrive come la ceramica propaga il segnale verso la porta in cui è applicato Z2
B_side2 = calcolaMatriceB(A, Z1); % la porta(o lato) 2 "vede" il carico Z1

% Prelevo il numero di coppie di ceramiche desiderate
numberOfCeramicPairs = numberOfCeramicPairsPicker();

% Calcolo la frazione dello spessore e della capacità
% statica che deve avere ciascuna coppia di ceramiche
new_l = l / (2 ^ numberOfCeramicPairs);
new_C0 = (2 ^ numberOfCeramicPairs) * C0;

% Rifaccio i calcoli per la coppia di ceramiche
% Matrici A(3x3), B(2x2) e G(3x3)
A_couple = calcolaMatriceA(ZoD, omega, v, new_l, h33, new_C0);

% Accoppio le ceramiche
G = calcolaMatriceG(A_couple, A_couple);

G_multiple = G;
if (numberOfCeramicPairs > 1)
    for n = 1 : (numberOfCeramicPairs-1)
        G_multiple = calcolaMatriceG(G_multiple, G_multiple);
    end
    G = G_multiple;
end

B_couple_side1 = calcolaMatriceB(G, Z2);
B_couple_side2 = calcolaMatriceB(G, Z1);

% Calcolo l'impedenza elettrica in ingresso
[Zin_side1, FTT_side1, FTR_side1] = calcolaFunzioniDiTrasferimento(B_side1, Z1, Zel);
[Zin_side2, FTT_side2, FTR_side2] = calcolaFunzioniDiTrasferimento(B_side2, Z2, Zel);

[Zin_couple_side1, FTT_couple_side1, FTR_couple_side1] = calcolaFunzioniDiTrasferimento(B_couple_side1, Z1, Zel);
[Zin_couple_side2, FTT_couple_side2, FTR_couple_side2] = calcolaFunzioniDiTrasferimento(B_couple_side2, Z2, Zel);

var_z = "Impedence Comparing ARIA-ARIA";
var_FTT = "TTF Comparing ARIA-ARIA";
var_FTR = "RTF Comparing ARIA-ARIA";

l_scaled = l * 1e+03;
new_l_scaled = new_l * 1e+03;
additionalDescriptions = " of " + string(l_scaled) + " [mm] thick ceramic";
additionalDescriptionsCouple = " of " + string(numberOfCeramicPairs) + " pair of " + string(new_l_scaled) + " [mm] thick ceramics";

figure(6)
stampaGrafici(f, Zin_side1{1}, Zin_side1{2}, var_z, 'blue', "Zin", "Zin", additionalDescriptions);
stampaGrafici(f, Zin_couple_side1{1}, Zin_couple_side1{2}, var_z, 'orange', "Zin", "Zin", additionalDescriptionsCouple);
hold on;

figure(7)
stampaGrafici(f, FTT_side1{1}, FTT_side1{2}, var_FTT, 'blue', "TTF", "TTF", additionalDescriptions);
stampaGrafici(f, FTT_couple_side1{1}, FTT_couple_side1{2}, var_FTT, 'orange', "TTF", "TTF", additionalDescriptionsCouple);
hold on;

figure(8)
stampaGrafici(f, FTR_side1{1}, FTR_side1{2}, var_FTR, 'blue', "RTF", "RTF", additionalDescriptions);
stampaGrafici(f, FTR_couple_side1{1}, FTR_couple_side1{2}, var_FTR, 'orange', "RTF", "RTF", additionalDescriptionsCouple);
hold on;

%% ACQUA-ACQUA
% Impedenza acustica specifica del mezzo
z1 = 1479036; % Rayl(Kg s^-1 m^-2) ACQUA
z2 = 1479036; % Rayl(Kg s^-1 m^-2) ACQUA

% Impedenza acustica del mezzo
Z1 = areaFaccia * z1;
Z2 = areaFaccia * z2;
 
% Matrici A(3x3), B(2x2) e G(3x3)
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_side1 = calcolaMatriceB(A, Z2); % la porta(o lato) 1 "vede" il carico Z2, B descrive come la ceramica propaga il segnale verso la porta in cui è applicato Z2
B_side2 = calcolaMatriceB(A, Z1); % la porta(o lato) 2 "vede" il carico Z1

% Calcolo la frazione dello spessore e della capacità
% statica che deve avere ciascuna coppia di ceramiche
new_l = l / (2 ^ numberOfCeramicPairs);
new_C0 = (2 ^ numberOfCeramicPairs) * C0;

% Rifaccio i calcoli per la coppia di ceramiche
% Matrici A(3x3), B(2x2) e G(3x3)
A_couple = calcolaMatriceA(ZoD, omega, v, new_l, h33, new_C0);

% Accoppio le ceramiche
G = calcolaMatriceG(A_couple, A_couple);

G_multiple = G;
if (numberOfCeramicPairs > 1)
    for n = 1 : (numberOfCeramicPairs-1)
        G_multiple = calcolaMatriceG(G_multiple, G_multiple);
    end
    G = G_multiple;
end

B_couple_side1 = calcolaMatriceB(G, Z2);
B_couple_side2 = calcolaMatriceB(G, Z1);

% Calcolo l'impedenza elettrica in ingresso
[Zin_side1, FTT_side1, FTR_side1] = calcolaFunzioniDiTrasferimento(B_side1, Z1, Zel);
[Zin_side2, FTT_side2, FTR_side2] = calcolaFunzioniDiTrasferimento(B_side2, Z2, Zel);

[Zin_couple_side1, FTT_couple_side1, FTR_couple_side1] = calcolaFunzioniDiTrasferimento(B_couple_side1, Z1, Zel);
[Zin_couple_side2, FTT_couple_side2, FTR_couple_side2] = calcolaFunzioniDiTrasferimento(B_couple_side2, Z2, Zel);

var_z = "Impedence Comparing ACQUA-ACQUA";
var_FTT = "TTF Comparing ACQUA-ACQUA";
var_FTR = "RTF Comparing ACQUA-ACQUA";

l_scaled = l * 1e+03;
new_l_scaled = new_l * 1e+03;
additionalDescriptions = " of " + string(l_scaled) + " [mm] thick ceramic";
additionalDescriptionsCouple = " of " + string(numberOfCeramicPairs) + " pair of " + string(new_l_scaled) + " [mm] thick ceramics";

figure(9)
stampaGrafici(f, Zin_side1{1}, Zin_side1{2}, var_z, 'blue', "Zin", "Zin", additionalDescriptions);
stampaGrafici(f, Zin_couple_side1{1}, Zin_couple_side1{2}, var_z, 'orange', "Zin", "Zin", additionalDescriptionsCouple);
hold on;

figure(10)
stampaGrafici(f, FTT_side1{1}, FTT_side1{2}, var_FTT, 'blue', "TTF", "TTF", additionalDescriptions);
stampaGrafici(f, FTT_couple_side1{1}, FTT_couple_side1{2}, var_FTT, 'orange', "TTF", "TTF", additionalDescriptionsCouple);
hold on;

figure(11)
stampaGrafici(f, FTR_side1{1}, FTR_side1{2}, var_FTR, 'blue', "RTF", "RTF", additionalDescriptions);
stampaGrafici(f, FTR_couple_side1{1}, FTR_couple_side1{2}, var_FTR, 'orange', "RTF", "RTF", additionalDescriptionsCouple);
hold on;

% Calcolo Keff^2
% index_min = (Zin_side1{1} == min(Zin_side1{1}));
% index_max = (Zin_side1{1} == max(Zin_side1{1}));
% fmin = f(1,index_min);
% fmax = f(1,index_max);
% Keff = ((fmax^2) - (fmin^2))/(fmax^2);
% cprintf('Comments', "\n");
% cprintf('Comments', "Risultato calcolo fattore di accoppiamento efficace:\n");
% cprintf('Comments', "Keff^2 = " + string(Keff) + "\n");
