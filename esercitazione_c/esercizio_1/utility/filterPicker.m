function scelta = filterPicker()
    %FILTERPICKER permette di scegliere un filtro tra quelli disponibili
    cprintf('Text', "Selezionare un filtro tra quelli disponibili: \n");
    cprintf('Text', '\t 1) Filtro di Lee \n');
    cprintf('Text', '\t 2) Filtro SRAD\n');
    
    scelta = convalidaInput(2);
    cprintf('Comments', "\n");
end