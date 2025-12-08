% Questo script data una cartella "db" contenente in n sottocartelle le
% immagini 2D del'impronta del palmo di n campioni, effettua le seguenti
% operazioni:
%  - Preprocessing;
%  - Features Extraction;
%  - Matching;
%  - Verification;
%  - Identification

addpath('./core/');
addpath('./utility/');
addpath('./external/');
evalin('base', 'clear'), close all; clc;

cprintf('Comments', "+------------------------------------2-D TEMPLATE GENERATION------------------------------------+\n");
cprintf('Comments', "\n");

cprintf('Comments', "+------------------Preprocessing/Features Extraction------------------+\n");
% Generazione percorsi
percorsoCorrente     = pwd + string(filesep);
percorsoDBImmagini   = fullfile(percorsoCorrente, "db") + string(filesep);
percorsoProcessing   = fullfile(percorsoCorrente, "processing", '') + string(filesep);
percorsoTemplates    = fullfile(percorsoCorrente, "templates", '') + string(filesep);
percorsoMatching     = fullfile(percorsoCorrente, "matching", '') + string(filesep);
percorsoRisultati    = fullfile(percorsoCorrente, "out", '') + string(filesep);
creaCartella(percorsoProcessing);creaCartella(percorsoTemplates);
creaCartella(percorsoMatching);creaCartella(percorsoRisultati);

% Dato un percorso assoluto la funzione predefinita dir restituisce, come
% la stessa funzione cmd, la lista dei file e delle cartelle presenti al
% detto percorso. Questa lista è restituita come una struct che però
% contiene anche come di consueto i percorsi . e .. che vengono
% successivamente scartati.
filesStruct = dir(percorsoDBImmagini);
filesStruct(1:2) = [];

scelta = filterPicker();

% Caricamento delle immagini delle impronte del palmo 2D e Preprocessing/Features Extraction
cprintf('Comments', "Elaborazione immagini iniziata...\n");
for i = 1 : size(filesStruct,1)
    nomeCampione = filesStruct(i).name;
    percorsoImmaginiCampione   = fullfile(percorsoDBImmagini, nomeCampione) + string(filesep);
    percorsoProcessingCampione = fullfile(percorsoProcessing, nomeCampione) + string(filesep);
    percorsoTemplatesCampione  = fullfile(percorsoTemplates, nomeCampione)  + string(filesep);
    creaCartella(percorsoProcessingCampione);creaCartella(percorsoTemplatesCampione);
    
    % struct che contiene le immagini dell'utente
    immaginiCampione = dir(percorsoImmaginiCampione);
    immaginiCampione(1:2) = [];
    for j = 1 : size(immaginiCampione,1)
        nomeImmagine = immaginiCampione(j).name;
        idx1 = find(nomeImmagine == '_', 1, 'last');  % posizione dell'ultimo underscore
        idx2 = find(nomeImmagine == '.', 1, 'last');  % posizione dell'ultimo punto
        numStr = nomeImmagine(idx1+1:idx2-1);
        percorsoImmagineDaElaborare = fullfile(percorsoImmaginiCampione, nomeImmagine);
        % Estrazione e salvataggio dei template
        template = estraiTemplate(percorsoImmagineDaElaborare,percorsoProcessingCampione,numStr,scelta);
        imwrite(template, strcat(percorsoTemplatesCampione,'template_', numStr, '.jpg'));
        save(strcat(percorsoTemplatesCampione,'template_', numStr, '.mat'), 'template');
    end

end
cprintf('Comments', "Elaborazione immagini terminata!\n");
cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n");
cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");



cprintf('Comments', "+-------------------------------EXPERIMENTAL RESULTS AND ANALYSIS-------------------------------+\n");
cprintf('Comments', "\n");

% Matching
cprintf('Comments', "+------------------------------Matching-------------------------------+\n");

% matching2D(percorsoTemplates,percorsoMatching)
% load(strcat(percorsoMatching,'/TabellaScore.mat'));
% writetable(tabellaScore, strcat(percorsoMatching,'/tabellaScore.xlsx'));
% disp(tabellaScore)

cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n");


% Stampa dei grafici
cprintf('Comments', "+---------------------------Stampa Grafici----------------------------+\n");

% plotStatistiche(percorsoRisultati,tabellaScore)

cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n")
cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
cprintf('Comments', "\n");cprintf('Comments', "\n");
