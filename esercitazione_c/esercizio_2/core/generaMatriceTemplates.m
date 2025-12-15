function [matriceOutput, sliceIds] = generaMatriceTemplates(percorsoTemplatesAcquisizione)
    % GENERAMATRICECONTENENTETEMPLATE legge template_*.mat (o fallback template_*.jpg) e crea una matrice Z×X×Y (depth × rows × cols)

    filesMat = dir(fullfile(percorsoTemplatesAcquisizione, "template_*.mat"));
    useMat = ~isempty(filesMat);

    if ~useMat
        filesJpg = dir(fullfile(percorsoTemplatesAcquisizione, "template_*.jpg"));
        if isempty(filesJpg)
            matriceOutput = [];
            sliceIds = [];
            return;
        end
        files = filesJpg;
    else
        files = filesMat;
    end

    % Estrazione indice numerico per sorting
    n = numel(files);
    sliceIds = nan(n,1);
    for k = 1:n
        name = string(files(k).name);                 % es: template_4.mat
        base = extractBefore(name, ".");              % template_4
        idStr = extractAfter(base, "template_");      % 4
        sliceIds(k) = str2double(idStr);
    end

    % Ordino (NaN alla fine)
    [~, ord] = sortrows([isnan(sliceIds), sliceIds], [1 2]);
    files = files(ord);
    sliceIds = sliceIds(ord);

    % Leggo il primo per ricavare la size
    first = leggiTemplateFile(fullfile(percorsoTemplatesAcquisizione, files(1).name), useMat);
    if isempty(first)
        matriceOutput = [];
        sliceIds = [];
        return;
    end

    % Normalizzo a binario/logico
    first = first > 0;
    [rows, cols] = size(first);

    depth = numel(files);
    matriceOutput = false(depth, rows, cols);
    matriceOutput(1,:,:) = first;

    for k = 2:depth
        T = leggiTemplateFile(fullfile(percorsoTemplatesAcquisizione, files(k).name), useMat);
        if isempty(T)
            continue;
        end

        if ndims(T) == 3
            T = rgb2gray(T);
        end

        T = T > 0;

        % Se per qualche motivo la size non combacia, riallineo (nearest per maschere)
        if ~isequal(size(T), [rows cols])
            T = imresize(T, [rows cols], "nearest");
        end

        matriceOutput(k,:,:) = T;
    end
end


