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
generaTemplates3D(percorsoTemplates);
cprintf('Comments', "\n");
cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");

% %% 3) Matching
% %Generiamo la tabella finale con gli score dei confronti
% disp(newline)
% disp('+----------Matching iniziato-------+');
% alpha = 2;
% matching3DParallel(alpha,templateDir);
% filterName = templateDir(9:end);
% load(fullfile(pwd, strcat('Matching/','TabellaScore',filterName,'_',num2str(alpha),'.mat')));
% disp(tabellaScore)
% disp('+---------Matching completato------+');
% disp('Program paused, press any key to continue...')
% pause();
% 
% %% 4) Stampa grafici
% disp(newline)
% disp('+----------Plotting grafici iniziato-------+');
% plotStatistiche(alpha,filterName,tabellaScore)
% disp('+----------Palmprint 3D completato---------+');