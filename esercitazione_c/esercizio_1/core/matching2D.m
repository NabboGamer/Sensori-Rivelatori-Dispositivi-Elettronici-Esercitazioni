function matching2D(percorsoTemplates, percorsoMatching)
    
    p = gcp('nocreate');
    if isempty(p)
        parpool('local');
    end
    
    % Preparazione e lettura template
    cartellaTemplates = dir(percorsoTemplates);
    cartellaTemplates(1:2) = [];
    templatesCellArray  = {};
    fileNamesCellArray = {};
    for i=1:size(cartellaTemplates,1)
    
        nomeCampione = cartellaTemplates(i).name;
        percorsoTemplatesCampione = fullfile(percorsoTemplates, nomeCampione);
        templatesCampione = dir(percorsoTemplatesCampione);
        templatesCampione(1:2) = [];
        for j = 1 : size(templatesCampione,1)
    
            nomeTemplate = templatesCampione(j).name;

            estensione = extractAfter(nomeTemplate, '.');
            if strcmp(estensione,'mat')
                templateMat = fullfile(percorsoTemplatesCampione, nomeTemplate);
                templatesCellArray{end+1,1}  = importdata(templateMat);
                fileNamesCellArray{end+1,1} = strcat(nomeCampione, '_', nomeTemplate);
            end
    
        end
    
    end
    
    n = length(templatesCellArray);
    score = zeros(n); 
    
    % Calcolo lo score per ogni combinazione (ordine non importante)
    for i = 1:n
        tmp1 = templatesCellArray{i,1};
        parfor j = i+1:n
            tmp2 = templatesCellArray{j,1};
            score(i,j) = calcolaScore2D(tmp1, tmp2);
        end
    end
    
    % Numero di template
    n = length(fileNamesCellArray);
    % Numero di coppie (i,j) con i < j
    numPairs = n * (n - 1) / 2;
    % Preallocazione: cell array numPairs x 3
    tabellaFinale = cell(numPairs, 3);
    sp = 1;
    for i = 1:n
        name1 = erase(string(fileNamesCellArray{i}), ".mat");
        for j = i+1:n
            name2 = erase(string(fileNamesCellArray{j}), ".mat");
    
            tabellaFinale{sp,1} = name1;
            tabellaFinale{sp,2} = name2;
            tabellaFinale{sp,3} = score(i,j);
    
            sp = sp + 1;
        end
    end
    
    tabellaScore = cell2table(tabellaFinale, 'VariableNames', {'Template1' 'Template2' 'Score'});
    tabellaScore.Template1 = categorical(tabellaScore.Template1);
    tabellaScore.Template2 = categorical(tabellaScore.Template2);

    save(fullfile(percorsoMatching,"tabellaScore.mat"), 'tabellaScore');
    
end