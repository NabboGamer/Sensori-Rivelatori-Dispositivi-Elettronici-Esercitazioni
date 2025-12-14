function elaboraImmagini()
    
    cprintf('Comments', "Elaborazione immagini iniziata...\n");
    cprintf('Comments', "\n");
    % ----------------------------
    % 1) Generazione percorsi
    % ----------------------------
    percorsoCorrente     = pwd + string(filesep);
    percorsoDBImmagini   = fullfile(percorsoCorrente, "db",         string(filesep));
    percorsoProcessing   = fullfile(percorsoCorrente, "processing", string(filesep));
    percorsoTemplates    = fullfile(percorsoCorrente, "templates",  string(filesep));
    percorsoMatching     = fullfile(percorsoCorrente, "matching",   string(filesep));
    percorsoRisultati    = fullfile(percorsoCorrente, "out",        string(filesep));
    creaCartella(percorsoProcessing);creaCartella(percorsoTemplates);
    creaCartella(percorsoMatching);creaCartella(percorsoRisultati);
    
    % ----------------------------
    % 2) Scelte filtri
    % ----------------------------
    sceltaFiltroDenoising   = denoisingFilterPicker();  
    sceltaFiltroEnhancement = enhancementFilterPicker();

    % -----------------------------------
    % 3) Cartella processing e template
    % -----------------------------------
    cartellaProcessingSetupCorrenteFiltri = sprintf("processing_%s_%s", sceltaFiltroDenoising, sceltaFiltroEnhancement);
    percorsoProcessing = fullfile(percorsoProcessing, cartellaProcessingSetupCorrenteFiltri);
    creaCartella(percorsoProcessing);
    cartellaTemplatesSetupCorrenteFiltri = sprintf("templates_%s_%s", sceltaFiltroDenoising, sceltaFiltroEnhancement);
    percorsoTemplates = fullfile(percorsoTemplates, cartellaTemplatesSetupCorrenteFiltri);
    creaCartella(percorsoTemplates);

    % ----------------------------
    % 4) Scansione file
    % ----------------------------
    sottoCartelleUtenti = dir(percorsoDBImmagini);
    sottoCartelleUtenti = sottoCartelleUtenti([sottoCartelleUtenti.isdir]);
    sottoCartelleUtenti = sottoCartelleUtenti(~ismember({sottoCartelleUtenti.name}, {'.','..'}));

    % cprintf('Comments', "Generazione file .mat e .jpg in corso \n");

    tStart = tic;

    % ----------------------------
    % 5) Loop utenti + immagini
    % ----------------------------
    for i = 1 : numel(sottoCartelleUtenti)
        % Scendo nelle cartelle dei vari utenti
        cartellaUtenteCorrente = sottoCartelleUtenti(i).name;
        percorsoCartellaUtenteCorrente = fullfile(percorsoDBImmagini, cartellaUtenteCorrente);
        % Creo la relativa cartella di processing
        percorsoProcessingUtenteCorrente = fullfile(percorsoProcessing, cartellaUtenteCorrente);
        creaCartella(percorsoProcessingUtenteCorrente);
        % Creo la relativa cartella di templates
        percorsoTemplatesUtenteCorrente = fullfile(percorsoTemplates, cartellaUtenteCorrente);
        creaCartella(percorsoTemplatesUtenteCorrente);

        sottoCartelleAcquisizioniUtenteCorrente = dir(percorsoCartellaUtenteCorrente);
        sottoCartelleAcquisizioniUtenteCorrente = sottoCartelleAcquisizioniUtenteCorrente([sottoCartelleAcquisizioniUtenteCorrente.isdir]);
        sottoCartelleAcquisizioniUtenteCorrente = sottoCartelleAcquisizioniUtenteCorrente(~ismember({sottoCartelleAcquisizioniUtenteCorrente.name}, {'.','..'}));
        for j = 1 : numel(sottoCartelleAcquisizioniUtenteCorrente)
            % Scendo nelle cartelle delle varie acquisizioni dei vari utenti
            cartellaAcquisizioneUtenteCorrente = sottoCartelleAcquisizioniUtenteCorrente(j).name;
            percorsoCartellaAcquisizioneUtenteCorrente = fullfile(percorsoCartellaUtenteCorrente, cartellaAcquisizioneUtenteCorrente, string(filesep));
            % Creo la relativa cartella di processing
            percorsoProcessingAcquisizioneUtenteCorrente = fullfile(percorsoProcessingUtenteCorrente, cartellaAcquisizioneUtenteCorrente, string(filesep));
            creaCartella(percorsoProcessingAcquisizioneUtenteCorrente);
            % Creo la relativa cartella di templates
            percorsoTemplatesAcquisizioneUtenteCorrente = fullfile(percorsoTemplatesUtenteCorrente, cartellaAcquisizioneUtenteCorrente, string(filesep));
            creaCartella(percorsoTemplatesAcquisizioneUtenteCorrente);
            
            % INFINE elenco i vari file jpg per la corrente acquisizione del corrente utente
            filesJpg  = dir(fullfile(percorsoCartellaAcquisizioneUtenteCorrente, "*.jpg"));
            if isempty(filesJpg)
                continue;
            end
            
            for k = 1:numel(filesJpg)
                nomeImmagine = filesJpg(k).name;
                base   = extractBefore(nomeImmagine, ".jpg");
                numStr = extractAfter(base, "immagine");
                percorsoImmagineDaElaborare = fullfile(percorsoCartellaAcquisizioneUtenteCorrente, nomeImmagine);
                if sceltaFiltroEnhancement == "dog"
                    templateImg = generaTemplateDoG(percorsoImmagineDaElaborare, percorsoProcessingAcquisizioneUtenteCorrente, numStr, sceltaFiltroDenoising);
                elseif sceltaFiltroEnhancement == "bh4"
                    templateImg = generaTemplateBH4(percorsoImmagineDaElaborare, percorsoProcessingAcquisizioneUtenteCorrente, numStr, sceltaFiltroDenoising);
                end
                
                imwrite(templateImg, strcat(percorsoTemplatesAcquisizioneUtenteCorrente,'template_', numStr, '.jpg'));
                save(strcat(percorsoTemplatesAcquisizioneUtenteCorrente,'template_', numStr, '.mat'), 'templateImg');
            end

        end
        
    end

    sec = toc(tStart);
    cprintf('Comments', "Elaborazione immagini terminata dopo %.3f secondi!\n", sec);
end
