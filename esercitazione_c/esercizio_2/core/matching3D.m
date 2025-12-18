function tabellaScore = matching3D(percorsoTemplates, percorsoMatching, alpha)
    %MATCHING3DPARALLEL Matching 3D tra tutti i template_3d.mat sotto percorsoTemplates

    arguments
        percorsoTemplates {mustBeTextScalar}
        percorsoMatching {mustBeTextScalar}
        alpha (1,1) double {mustBeFinite, mustBeReal}
    end

    % Avvia pool se non attivo
    if isempty(gcp("nocreate"))
        parpool();
    end
    
    cprintf('Comments', "Calcolo dei matching scores iniziato...\n");
    cprintf('Comments', "\n");
    tStart = tic;

    % 1) Cerca tutti i template_3d.mat (ricorsivo)
    files = dir(fullfile(percorsoTemplates, "**", "template_3d.mat"));
    files = files(~[files.isdir]);
    
    n = numel(files);
    if n < 2
        cprintf('SystemCommands', "Trovati %d template. Servono almeno 2 per fare matching.", numel(files));
        tabellaScore = table(string.empty(0,1), string.empty(0,1), [], 'VariableNames', {'Utente1','Utente2','Score'});
        return;
    end

    % 2) Carica template (matriceOutput) + ricava ID campione dalla cartella
    ids = strings(n,1);
    templates = cell(n,1);

    for k = 1:n
        fullPath = fullfile(files(k).folder, files(k).name);

        % .../<NomeUtente>/<NomeUtente_XXX>/template_3d.mat  -> ID = <NomeUtente_XXX>
        [~, sampleFolder] = fileparts(files(k).folder);
        ids(k) = string(sampleFolder);

        S = load(fullPath, "matriceOutput");
        if ~isfield(S, "matriceOutput")
            cprintf('Errors', "Nel file %s non esiste la variabile 'matriceOutput'.", fullPath);
        end
        templates{k} = S.matriceOutput;
    end

    % 3) Indici di tutte le coppie (i<j) senza allocare score(n,n)
    numPairs = n*(n-1)/2;
    idx1 = zeros(numPairs, 1, "uint32");
    idx2 = zeros(numPairs, 1, "uint32");

    t = 1;
    for i = 1:n-1
        for j = i+1:n
            idx1(t) = i;
            idx2(t) = j;
            t = t + 1;
        end
    end

    % 4) Matching parallelo
    scoreVec = zeros(numPairs, 1);
    confVec = strings(numPairs, 1);
    % Copia read-only dei template su ogni worker (meno overhead nel parfor)
    templatesConst = parallel.pool.Constant(templates);
    idsConst = parallel.pool.Constant(ids);

    parfor t = 1:numPairs
        i = idx1(t);
        j = idx2(t);
        tmp1 = templatesConst.Value{i}; % accesso alla copia locale del worker
        tmp2 = templatesConst.Value{j};
        scoreVec(t) = calcolaScore3D(tmp1, tmp2, alpha);

        nomeUtente1 = extractBefore(idsConst.Value{i}, "_");
        nomeUtente2 = extractBefore(idsConst.Value{j}, "_");
        if(strcmp(nomeUtente1,nomeUtente2)) 
            confVec(t) = "Genuino";
        else
            confVec(t) = "Impostore";
        end
    end

    % 5) Tabella finale
    tabellaScore = table( ids(double(idx1)), ...
                          ids(double(idx2)), ...
                          scoreVec, ...
                          confVec, ...
                          'VariableNames', {'Template1','Template2','Score','Confronto'} );
    tabellaScore.Template1 = categorical(tabellaScore.Template1);
    tabellaScore.Template2 = categorical(tabellaScore.Template2);
    tabellaScore.Confronto = categorical(tabellaScore.Confronto);

    sec = toc(tStart);
    cprintf('Comments', "Calcolo dei matching scores terminato dopo %.3f secondi!\n", sec);
    cprintf('Comments', "\n");

    % 6) Salvataggio
    % nome filtro dal nome cartella root: templates_lee_bh4_3d -> lee_bh4
    [~, rootName] = fileparts(percorsoTemplates);
    filterName = extractAfter(string(rootName), "templates_");
    filterName = extractBefore(filterName, "_3d");

    outNameMatFile = "tabella_score_" + filterName + "_" + num2str(alpha) + ".mat";
    outNameXlsxFile = "tabella_score_" + filterName + "_" + num2str(alpha) + ".xlsx";
    save(fullfile(percorsoMatching, outNameMatFile), "tabellaScore");
    writetable(tabellaScore, fullfile(percorsoMatching, outNameXlsxFile));
end
