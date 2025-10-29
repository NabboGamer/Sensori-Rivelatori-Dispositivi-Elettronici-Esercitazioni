function guadagno = concentratorGainPicker()
    %CONCENTRATORGAINPICKER permette di acquisire il guadagno massimo che il concentratore deve ottenere in risonanza

    cprintf('Text',"\n");
    cprintf('Text', "Inserire il guadagno desiderato in risonanza per il concentratore: ");
    guadagno = input("guadagno=");

    if (guadagno < 1)
        cprintf('Errors', "Il numero inserito NON è maggiore di 1, prego reinserire...\n");
        guadagno = concentratorGainPicker();
    end

end