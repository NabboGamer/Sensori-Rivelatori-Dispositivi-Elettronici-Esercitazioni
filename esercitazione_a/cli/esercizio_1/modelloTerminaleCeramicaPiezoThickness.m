% Questo script implementa il modello terminale dell'elemento 
% piezoelettrico(nel nostro caso una ceramica piezoelettrica) nel modo 
% tickness(siccome lo spessore è nettamente inferiore alle altre dimensioni)

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

[areaFaccia, l, rho, c33, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

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

% Matrici A(3x3) e B(2x2)
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_side1 = calcolaMatriceB(A, Z2); % la porta(o lato) 1 "vede" il carico Z2, B descrive come la ceramica propaga il segnale verso la porta in cui è applicato Z2
B_side2 = calcolaMatriceB(A, Z1); % la porta(o lato) 2 "vede" il carico Z1

% Calcolo l'impedenza elettrica in ingresso
[Zin_side1, FTT_side1, FTR_side1] = calcolaFunzioniDiTrasferimento(B_side1, Z1, Zel);
[Zin_side2, FTT_side2, FTR_side2] = calcolaFunzioniDiTrasferimento(B_side2, Z2, Zel);

if(Z1 == Z2)
    var_z = "Impedance";
    var_FTT = "TTF";
    % var_TTF_i = "TTF_i";
    var_FTR = "RTF";
else
    var_z = "Impedance";
    var_FTT = "TTF Comparing";
    % var_TTF_i = "TTF_i Comparing";
    var_FTR = "RTF Comparing";
end

figure(1);
stampaGrafici(f, Zin_side1{1}, Zin_side1{2}, var_z, 'blue', "Zin");
% stampaGrafici(f, Zin_side2{1}, Zin_side2{2}, var_z, 'orange', "Z_s_i_d_e_2"); % l'impedenza in ingresso risultante Zin è la stessa quando il sistema è simmetrico
hold on;

figure(2);
stampaGrafici(f, FTT_side1{1}, FTT_side1{2}, var_FTT, 'blue', "TTF_s_i_d_e_1", "TTF");
stampaGrafici(f, FTT_side2{1}, FTT_side2{2}, var_FTT, 'orange', "TTF_s_i_d_e_2", "TTF");
hold on;

% Grafico della funzione di trasferimento se la ceramica viene pilotata in corrente
% figure(3);
% Grafico(f,TTF_Z1_i{1},TTF_Z1_i{2}, var_TTF_i, 'blue');
% Grafico(f,TTF_Z2_i{1}, TTF_Z2_i{2}, var_TTF_i, 'orange');
% hold on;

figure(4);
stampaGrafici(f, FTR_side1{1}, FTR_side1{2}, var_FTR, 'blue', "RTF_s_i_d_e_1", "RTF");
stampaGrafici(f, FTR_side2{1}, FTR_side2{2}, var_FTR, 'orange', "RTF_s_i_d_e_2", "RTF");
hold on;

% Calcolo Keff^2
index_min = (Zin_side1{1} == min(Zin_side1{1}));
index_max = (Zin_side1{1} == max(Zin_side1{1}));
fmin = f(1,index_min);
fmax = f(1,index_max);
Keff = ((fmax^2) - (fmin^2))/(fmax^2);
cprintf('Comments', "\n");
cprintf('Comments', "Risultato calcolo fattore di accoppiamento efficace:\n");
cprintf('Comments', "Keff^2 = " + string(Keff) + "\n");
