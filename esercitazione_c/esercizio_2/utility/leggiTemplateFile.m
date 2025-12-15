function T = leggiTemplateFile(fullPath, isMat)
    % LEGGITEMPLATEFILE si occupa di caricare template da file .mat (variabile templateImg) o da file .jpg

    try
        if isMat
            S = load(fullPath);
            if isfield(S, "templateImg")
                T = S.templateImg;
            else
                % fallback: prendo il primo campo disponibile
                fn = fieldnames(S);
                T = S.(fn{1});
            end
        else
            T = imread(fullPath);
        end

        if isa(T, "uint8") || isa(T, "uint16") || isa(T, "double") || isa(T, "single") || islogical(T)
            % ok
        else
            T = double(T);
        end

        if ndims(T) == 3
            T = rgb2gray(T);
        end
    catch
        T = [];
    end

end