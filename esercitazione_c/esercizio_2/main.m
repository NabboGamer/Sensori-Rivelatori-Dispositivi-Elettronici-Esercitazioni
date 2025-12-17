% Questo script data una cartella "db" contenente n sottocartelle di utenti 
% contenenti caiscuna n sottocartelle di acquisizioni contenenti ciascuna n
% immagini 2D del'impronta del palmo, effettua le seguenti operazioni:
%  - Preprocessing;
%  - Features Extraction;
%  - Matching;
%  - Calcolo Statistiche.

addpath('./core/');
addpath('./utility/');
addpath('./external/');
evalin('base', 'clear'), close all; clc;

%% 0) Generazione percorsi
percorsoCorrente     = pwd + string(filesep);
percorsoDBImmagini   = fullfile(percorsoCorrente, "db",         string(filesep));
percorsoProcessing   = fullfile(percorsoCorrente, "processing", string(filesep));
percorsoTemplates    = fullfile(percorsoCorrente, "templates",  string(filesep));
percorsoMatching     = fullfile(percorsoCorrente, "matching",   string(filesep));
percorsoRisultati    = fullfile(percorsoCorrente, "out",        string(filesep));
creaCartella(percorsoProcessing);creaCartella(percorsoTemplates);
creaCartella(percorsoMatching);creaCartella(percorsoRisultati);


%% 1) Caricamento delle immagini e generazione dei template
cprintf('Comments', "+------------------------------------2-D TEMPLATE GENERATION------------------------------------+\n");
cprintf('Comments', "\n");
cprintf('Comments', "+------------------Preprocessing/Features Extraction------------------+\n");
percorsoTemplates = generaTemplates2D(percorsoDBImmagini, percorsoProcessing, percorsoTemplates);
cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n");
cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");


%% 2) Generazione dei template 3D
cprintf('Comments', "+------------------------------------3-D TEMPLATE GENERATION------------------------------------+\n");
cprintf('Comments', "\n");
percorsoTemplates3D = generaTemplates3D(percorsoTemplates);
cprintf('Comments', "\n");
cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");


cprintf('Comments', "+-------------------------------EXPERIMENTAL RESULTS AND ANALYSIS-------------------------------+\n");
cprintf('Comments', "\n");

%% 3) Matching
cprintf('Comments', "+----------------------------------------Matching-----------------------------------------+\n");
cprintf('Comments', "\n");
alpha = 2;
tabellaScore = matching3D(percorsoTemplates3D, percorsoMatching, alpha);
disp(tabellaScore)
cprintf('Comments', "+-----------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");

%% 4) Stampa grafici
cprintf('Comments', "+------------------------Calcolo Statistiche--------------------------+\n");
calcolaStatistiche(tabellaScore);
cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n")

cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");