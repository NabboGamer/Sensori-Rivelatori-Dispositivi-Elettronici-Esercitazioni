function percorsoTemplates = generaTemplates2D(percorsoDBImmagini, percorsoProcessing, percorsoTemplates)
    %GENERATEMPLATES2D Genera template 2D a partire da un database di immagini.
    %
    %   Scansiona ricorsivamente la struttura del database immagini organizzata
    %   per utente e acquisizione, applica una pipeline di denoising ed
    %   enhancement scelta tramite picker, e salva per ogni immagine:
    %       - il template 2D in formato .jpg
    %       - il template 2D in formato .mat (variabile: templateImg)
    %
    %   La funzione crea automaticamente una sottocartella di "processing" e una
    %   di "templates" che includono nel nome la combinazione di filtri selezionata:
    %       processing_<denoising>_<enhancement>/
    %       templates_<denoising>_<enhancement>/
    %   mantenendo la stessa gerarchia di cartelle del DB:
    %       <utente>/<acquisizione>/
    
    cprintf('Comments', "Elaborazione immagini iniziata...\n");
    cprintf('Comments', "\n");
    tStart = tic;
    
    % ----------------------------
    % 1) Scelte filtri
    % ----------------------------
    sceltaFiltroDenoising   = denoisingFilterPicker();  
    sceltaFiltroEnhancement = enhancementFilterPicker();

    % -----------------------------------
    % 2) Cartella processing e template
    % -----------------------------------
    cartellaProcessingSetupCorrenteFiltri = sprintf("processing_%s_%s", sceltaFiltroDenoising, sceltaFiltroEnhancement);
    percorsoProcessing = fullfile(percorsoProcessing, cartellaProcessingSetupCorrenteFiltri);
    creaCartella(percorsoProcessing);
    cartellaTemplatesSetupCorrenteFiltri = sprintf("templates_%s_%s", sceltaFiltroDenoising, sceltaFiltroEnhancement);
    percorsoTemplates = fullfile(percorsoTemplates, cartellaTemplatesSetupCorrenteFiltri);
    creaCartella(percorsoTemplates);

    % ----------------------------
    % 3) Scansione file
    % ----------------------------
    sottoCartelleUtenti = dir(percorsoDBImmagini);
    sottoCartelleUtenti = sottoCartelleUtenti([sottoCartelleUtenti.isdir]);
    sottoCartelleUtenti = sottoCartelleUtenti(~ismember({sottoCartelleUtenti.name}, {'.','..'}));

    % cprintf('Comments', "Generazione file .mat e .jpg in corso \n");

    % ----------------------------
    % 4) Loop immagini
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
