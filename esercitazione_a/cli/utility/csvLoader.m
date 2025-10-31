function csv = csvLoader(completeFilePath)
    %CSVLOADER permette di caricare in memoria un file CSV dato il suo percorso completo su File System
    
    try
        % Trova le righe di inizio/fine sezione
        lines = readlines(completeFilePath);
        index_begin = find(startsWith(strtrim(lines), "BEGIN", "IgnoreCase", true), 1, "first");
        index_end   = find(startsWith(strtrim(lines), "END", "IgnoreCase", true), 1, "first");
        
        % Costruisco le import options
        opts = detectImportOptions(completeFilePath, ...
            "Delimiter", ",", ...
            "CommentStyle", "!", ...           % ignora le righe che iniziano con "!"
            "VariableNamingRule", "preserve"); % mantieni i nomi esatti della riga header
        
        opts.VariableNamesLine = index_begin + 1;                   % la riga subito dopo BEGIN è l'header
        opts.DataLines         = [index_begin + 2, index_end - 1];  % i dati stanno tra header e END
        opts.ExtraColumnsRule  = "ignore";
        opts.MissingRule       = "fill";
        
        % Import tabellare
        csv = readtable(completeFilePath, opts);
        
        % Rinomino le colonne con nomi comodi
        csv = renamevars(csv, csv.Properties.VariableNames, ["f","moduloZin","faseZin"]);
    catch exception
        csv = -1;
        cprintf('Errors', 'Qualcosa è andato storto durante il caricamento del file in memoria! \n');
        return;
    end
    

end