addpath('./utility/');
evalin('base', 'clear'), close all; clc;

cprintf('Comments', "+------------------Fase di pre-processing------------------+");
%% Generazione percorsi

percorsoCorrente     = pwd;
percorsoDBImmagini   = fullfile(percorsoCorrente, "db");
percorsoProcessing   = fullfile(percorsoCorrente, "processing");
percorsoTemplates    = fullfile(percorsoCorrente, "templates");
percorsoMatching     = fullfile(percorsoCorrente, "matching");
percorsoRisultati    = fullfile(percorsoCorrente, "out");

% Dato un percorso assoluto la funzione predefinita dir restituisce, come
% la stessa funzione cmd, la lista dei file e delle cartelle presenti al
% detto percorso. Questa lista è restituista come una struct che però
% contiene anche come di consueto i percorsi . e .. che vengono
% successivamente scartati.
filesStruct = dir(percorsoDBImmagini);
filesStruct(1:2) = [];

scelta = filterPicker();

%% Import delle immagini delle impronte del palmo 2D
for i = 1 : size(filesStruct,1)

    nomeCampione = filesStruct(i).name;
    percorsoImmaginiCampione   = fullfile(percorsoDBImmagini, nomeCampione);
    percorsoProcessingCampione = fullfile(percorsoProcessing, nomeCampione);
    percorsoTemplatesCampione  = fullfile(percorsoTemplates, nomeCampione);
    
    % struct che contiene le immagini dell'utente
    immaginiCampione = dir(percorsoImmaginiCampione);
    immaginiCampione(1:2) = [];

    for j = 1 : size(immaginiUtente,1)

        nomeImmagine = immaginiCampione(j).name;
        istante = nomeImmagine(end-4:end-4); %prende solo i valori numerici dal nome che indicano l'istante
        immagineDaElaborare = strcat(percorsoImmaginiCampione, '\', nomeImmagine);

%% 2.Estrazione e salvataggio dei template
        creaCartelle(percorsoProcessingCampione,percorsoTemplatesCampione,percorsoMatching,percorsoRisultati);
        [template] = estraiTemplate(immagineDaElaborare,percorsoProcessingCampione,istante,choice);
        imwrite(template,strcat(percorsoTemplatesCampione,'template_',istante,'.jpg'));
        save(strcat(percorsoTemplatesCampione,'template_',istante,'.dat'), 'template');
    end

end
disp('|-------Operazioni morfologiche completate-------|')
disp('+----------Immagini processate salvate-----------+')
disp('Program paused, press any key to continue...')
pause();
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
