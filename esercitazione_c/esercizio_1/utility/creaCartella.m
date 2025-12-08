function creaCartella(percorsoCartella)
    %CREASTRUTTURACARTELLE si occupa di creare una cartella necessaria al funzionamento del progetto

    if ~exist(percorsoCartella, 'dir')
        mkdir(percorsoCartella);
    end

end