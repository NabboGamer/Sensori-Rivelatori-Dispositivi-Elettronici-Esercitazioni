%TODO: Aggiungere intestazione script

addpath('./core/');
addpath('./utility/');
addpath('./external/');
evalin('base', 'clear'), close all; clc;

%% 1) Caricamento delle immagini e generazione dei template

cprintf('Comments', "+------------------------------------2-D TEMPLATE GENERATION------------------------------------+\n");
cprintf('Comments', "\n");
cprintf('Comments', "+------------------Preprocessing/Features Extraction------------------+\n");
elaboraImmagini();
cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n");
cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");


% %% 2) Generazione dei template 3D
% disp(newline)
% disp('+---------Generazione dei template 3D iniziato------+');
% generaTemplates3D(templateDir)
% disp('+---Template generati correttamente---+');
% disp('Program paused, press any key to continue...')
% pause();
% 
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