% Questo script implementa la caratterizzazione dell'elemento 
% piezoelettrico(nel nostro caso una ceramica piezoelettrica) nel modo 
% thickness(siccome lo spessore è nettamente inferiore alle altre dimensioni),
% supponendo che l'elemento sia meccanicamente isolato ovvero "a vuoto"

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

[~, l, rho, c33, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

% Calcolo l'impedenza di ingresso della ceramica
Zi = ( (1./(1i .* omega .* C0)) .* ( 1 - ( ((h33^2)/(c33*beta33)) .* (2./theta) .* tan(theta./2) ) ) );

% Calcolo modulo e fase
[moduloZi, faseZi] = calcolaModuloEFase(Zi, false, true);

% Stampa diagrammi di Bode
stampaGrafici(f, moduloZi, faseZi, "Zin: input impedance", "blue", "Zin");

% Calcolo Keff^2
index_min = (moduloZi == min(moduloZi));
index_max = (moduloZi == max(moduloZi));
fmin = f(1,index_min);
fmax = f(1,index_max);
Keff = ((fmax^2) - (fmin^2))/(fmax^2);
cprintf('Comments', "\n");
cprintf('Comments', "Risultato calcolo fattore di accoppiamento efficace:\n");
cprintf('Comments', "Keff^2 = " + string(Keff) + "\n");