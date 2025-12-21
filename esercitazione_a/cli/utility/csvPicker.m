function [csv, fileName] = csvPicker()
% CSVPICKER permette di scegliere tramite File Choser un file di tipo CSV

% Specifico i formati di file desiderati
desiredFormats = {'*.csv'};

% Apro il file choser
currentPath = pwd;
defaultPath = fullfile(currentPath, '..', '..', 'res');
defaultPath = char(java.io.File(defaultPath).getCanonicalPath());
[fileName, filePath] = uigetfile(desiredFormats, ...
    'Seleziona un file CSV da caricare', ...
    defaultPath);

% Controllo se l'utente ha premuto "Annulla" o ha chiuso la finestra
if isequal(fileName, 0)
    csv = -1;
    cprintf('Errors', 'Nessun file selezionato! \n');
    return;
end

% Rimuovo gli asterischi dalla stringa del formato del file
formatsDesiredWithoutAsterixes = cellfun(@(x) strrep(x, '*', ''), ...
    desiredFormats, ...
    'UniformOutput', false);

% Verifico se il file ha uno dei formati desiderati
validFormat = false;
for i = 1:length(formatsDesiredWithoutAsterixes)
    if endsWith(lower(fileName), lower(formatsDesiredWithoutAsterixes{i}))
        validFormat = true;
        break;
    end
end

if ~validFormat
    csv = -1;
    cprintf('Errors', 'Formato del file non valido! \n');
    return;
end

cprintf('Text', '\n');
cprintf('Text', 'CSV selezionato correttamente! \n');

completeFilePath = fullfile(filePath, fileName);

cprintf('Text', 'Prego attendere mentre il CSV viene caricato in memoria... \n');

oldWarnState = warning('query', 'all');
warning('off', 'all');
lastwarn('');
try
    csv = csvLoader(completeFilePath);
    [msg, ~] = lastwarn;
    if ~isempty(msg)
        cprintf('SystemCommands', 'Il file è in sola lettura! \n');
        lastwarn('');
    end
    warning(oldWarnState);
catch
    csv = -1;
end
cprintf('Text', 'CSV caricato correttamente in memoria! \n');

end