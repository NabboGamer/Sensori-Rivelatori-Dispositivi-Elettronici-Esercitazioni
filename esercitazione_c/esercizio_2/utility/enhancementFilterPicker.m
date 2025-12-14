function scelta = enhancementFilterPicker()
    %FILTERPICKER permette di scegliere un filtro di enhancement tra quelli disponibili

    % I filtri di enhancement provano a far emergere linee/solchi e 
    % dettagli delle immagini in modi diversi: DoG è un filtro lineare 
    % in scale-space; mentre BH4 è un filtro non-lineare morfologico che 
    % agisce sulle "dark features"
    cprintf('Text', "Selezionare un filtro di enhancement tra quelli disponibili: \n");
    cprintf('Text', '\t 1) Filtro Bottom Hat 4 directions (BH4) \n');
    cprintf('Text', '\t 2) Filtro Difference of Gaussians (DoG) \n');
    
    scelta = convalidaInput(2);
    if scelta == 1
        scelta = "bh4";
    else
        scelta = "dog";
    end
    cprintf('Comments', "\n");
end