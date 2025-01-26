% Questo script implementa la caratterizzazione dell'elemento 
% piezoelettrico(nel nostro caso una ceramica piezoelettrica) nel modo 
% tickness(siccome lo spessore è nettamente inferiore alle altre dimensioni),
% supponendo che l'elemento sia meccanicamente isolato ovvero "a vuoto"

addpath('../utility/');
evalin('base', 'clear'), close all; clc;

[~, l, rho, c33, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

% Calcolo l'impedenza di ingresso della ceramica
Zi = ( (1./(1i .* omega .* C0)) .* ( 1 - ( ((h33^2)/(c33*beta33)) .* (2./theta) .* tan(theta./2) ) ) );

% Calcolo modulo e fase
[moduloZi, faseZi] = calcolaModuloEFase(Zi);

% Stampa diagrammi di Bode
stampaGrafici(f, moduloZi, faseZi, "Zi: input impedance", "blue", "Zi");