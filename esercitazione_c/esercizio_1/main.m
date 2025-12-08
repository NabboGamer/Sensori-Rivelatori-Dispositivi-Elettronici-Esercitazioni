% Questo script data una cartella "db" contenente in n sottocartelle le
% immagini 2D del'impronta del palmo di n campioni, effettua le seguenti
% operazioni:
%  - Preprocessing;
%  - Features Extraction;
%  - Matching;
%  - Verification;
%  - Identification

addpath('./utility/');
addpath('./external/');
evalin('base', 'clear'), close all; clc;

cprintf('Comments', "+------------------------------------2-D TEMPLATE GENERATION------------------------------------+\n");
cprintf('Comments', "\n");

cprintf('Comments', "+------------------Preprocessing/Features Extraction------------------+\n");
%% Generazione percorsi

percorsoCorrente     = pwd;
percorsoDBImmagini   = fullfile(percorsoCorrente, "db");
percorsoProcessing   = fullfile(percorsoCorrente, "processing", '');
percorsoTemplates    = fullfile(percorsoCorrente, "templates", '');
percorsoMatching     = fullfile(percorsoCorrente, "matching", '');
percorsoRisultati    = fullfile(percorsoCorrente, "out", '');
creaCartella(percorsoProcessing);
creaCartella(percorsoTemplates);
creaCartella(percorsoMatching);
creaCartella(percorsoRisultati);

% Dato un percorso assoluto la funzione predefinita dir restituisce, come
% la stessa funzione cmd, la lista dei file e delle cartelle presenti al
% detto percorso. Questa lista è restituita come una struct che però
% contiene anche come di consueto i percorsi . e .. che vengono
% successivamente scartati.
filesStruct = dir(percorsoDBImmagini);
filesStruct(1:2) = [];

scelta = filterPicker();
cprintf('Comments', "\n");

%% Import delle immagini delle impronte del palmo 2D e Preprocessing/Features Extraction
for i = 1 : size(filesStruct,1)

    nomeCampione = filesStruct(i).name;
    percorsoImmaginiCampione   = fullfile(percorsoDBImmagini, nomeCampione);
    percorsoProcessingCampione = fullfile(percorsoProcessing, nomeCampione);
    percorsoTemplatesCampione  = fullfile(percorsoTemplates, nomeCampione);
    creaCartella(percorsoProcessingCampione); 
    creaCartella(percorsoTemplatesCampione);
    
    % struct che contiene le immagini dell'utente
    immaginiCampione = dir(percorsoImmaginiCampione);
    immaginiCampione(1:2) = [];

    for j = 1 : size(immaginiCampione,1)

        nomeImmagine = immaginiCampione(j).name;
        idx = find(nomeImmagine == '_', 1, 'last');  % posizione dell'ultimo underscore
        numStr = nomeImmagine(idx+1:end);
        immagineDaElaborare = fullfile(percorsoImmaginiCampione, nomeImmagine);

        % Estrazione e salvataggio dei template
        template = estraiTemplate(immagineDaElaborare,percorsoProcessingCampione,numStr,scelta);
        imwrite(template, strcat(percorsoTemplatesCampione,'template_', numStr, '.jpg'));
        save(strcat(percorsoTemplatesCampione,'template_', numStr, '.dat'), 'template');
    end

end

cprintf('Comments', "+---------------------------------------------------------------------+\n");
cprintf('Comments', "\n");


% 
% %% 3.Matching
% disp(newline)
% disp('+--------------Inizio il matching----------------+')
% matching2D(percorsoTemplates,percorsoMatching)
% load(strcat(percorsoMatching,'/TabellaScore.mat'));
% writetable(tabellaScore, strcat(percorsoMatching,'/tabellaScore.xlsx'));
% disp(tabellaScore)
% disp('+-------------Matching completato----------------+')
% disp('Program paused, press any key to continue...')
% pause();
% 
% %% 4.Stampa dei grafici
% disp(newline)
% disp('+----------------Stampa i grafici-----------------+')
% plotStatistiche(percorsoRisultati,tabellaScore)
% disp('+-------------Palmprint completato----------------+')

cprintf('Comments', "+-----------------------------------------------------------------------------------------------+\n");
