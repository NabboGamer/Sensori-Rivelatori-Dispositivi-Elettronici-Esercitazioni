% Dato un file csv in ingresso contenente le misurazioni di laboratorio 
% della TTF di una ceramica piezoelettrica, questo script si occupa di
% ricavare la tipologia più probabile di ceramica.

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

csv = csvPicker();

if isnumeric(csv) && isscalar(csv) && isreal(csv) && ~isnan(csv) && csv == -1
    return;
end
