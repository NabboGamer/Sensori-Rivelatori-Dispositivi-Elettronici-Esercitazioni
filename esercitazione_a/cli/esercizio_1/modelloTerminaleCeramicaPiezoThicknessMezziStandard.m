% Questo script implementa il modello terminale dell'elemento 
% piezoelettrico nel modo tickness.
% Rispetto allo script modelloTerminaleCeramicaPiezoThickness qui
% non viene permessa la selezione all'utente dei mezzi di contatto con i 
% due lati della ceramica di modo da fare un confronto con i mezzi 
% standard ovvero ARIA-ARIA e ACQUA-ACQUA.

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

[areaFaccia, l, rho, c33, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

% Impedenza acustica della ceramica in direzione z
ZoD = areaFaccia * v * rho;
        
% Impedenza acustica del carico
Zel = 1E+06; %1MOhm

var_z = "Impedance Comparing ARIA-ARIA vs ACQUA-ACQUA";
var_FTT = "TTF Comparing ARIA-ARIA vs ACQUA-ACQUA";
var_FTR = "RTF Comparing ARIA-ARIA vs ACQUA-ACQUA";
%% ARIA-ARIA
% Impedenza acustica specifica del mezzo
z1 = 414.5; % Rayl(Kg s^-1 m^-2) ARIA
z2 = 414.5; % Rayl(Kg s^-1 m^-2) ARIA

% Impedenza acustica del mezzo
Z1 = areaFaccia * z1;
Z2 = areaFaccia * z2;

% Matrici A(3x3) e B(2x2)
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_side1 = calcolaMatriceB(A, Z2); % la porta(o lato) 1 "vede" il carico Z2, B descrive come la ceramica propaga il segnale verso la porta in cui è applicato Z2

% Calcolo l'impedenza elettrica in ingresso
[Zin_side1, FTT_side1, FTR_side1] = calcolaFunzioniDiTrasferimento(B_side1, Z1, Zel);

figure(6);
stampaGrafici(f, Zin_side1{1}, Zin_side1{2}, var_z, 'blue', "Zin_A_R_I_A_-_A_R_I_A", "Zin");
hold on;

figure(7);
stampaGrafici(f, FTT_side1{1}, FTT_side1{2}, var_FTT, 'blue', "TTF_A_R_I_A_-_A_R_I_A", "TTF");
hold on;

figure(8);
stampaGrafici(f, FTR_side1{1}, FTR_side1{2}, var_FTR, 'blue', "RTF_A_R_I_A_-_A_R_I_A", "RTF");
hold on;

%% ACQUA-ACQUA
% Impedenza acustica specifica del mezzo
z1 = 1479036; % Rayl(Kg s^-1 m^-2) ACQUA
z2 = 1479036; % Rayl(Kg s^-1 m^-2) ACQUA

% Impedenza acustica del mezzo
Z1 = areaFaccia * z1;
Z2 = areaFaccia * z2;

% Matrici A(3x3) e B(2x2)
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_side1 = calcolaMatriceB(A, Z2); % la porta(o lato) 1 "vede" il carico Z2, B descrive come la ceramica propaga il segnale verso la porta in cui è applicato Z2

% Calcolo l'impedenza elettrica in ingresso
[Zin_side1, FTT_side1, FTR_side1] = calcolaFunzioniDiTrasferimento(B_side1, Z1, Zel);

figure(6);
stampaGrafici(f, Zin_side1{1}, Zin_side1{2}, var_z, 'orange', "Zin_A_C_Q_U_A_-_A_C_Q_U_A", "Zin");
hold on;

figure(7);
stampaGrafici(f, FTT_side1{1}, FTT_side1{2}, var_FTT, 'orange', "TTF_A_C_Q_U_A_-_A_C_Q_U_A", "TTF");
hold on;

figure(8);
stampaGrafici(f, FTR_side1{1}, FTR_side1{2}, var_FTR, 'orange', "RTF_A_C_Q_U_A_-_A_C_Q_U_A", "RTF");
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
