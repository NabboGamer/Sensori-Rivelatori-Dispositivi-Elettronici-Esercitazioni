function z = specificAcousticImpedancePicker(numeroMezzo)
    % SPECIFICACOUSTICIMPEDANCEPICKER permette di scegliere il mezzo a contatto con la ceramica piezoelettrica, per ottenere la relativa impedenza acustica specifica
    
    cprintf('Text',"\n");
    cprintf('Text', "Selezionare il %sº mezzo da mettere a contatto con la ceramica piezoelettrica tra quelli disponibili: \n", string(numeroMezzo));
    cprintf('Text', '\t 1) Acqua(20°C) \n');
    cprintf('Text', '\t 2) Aria(20°C) \n');
    cprintf('Text', '\t 3) Alcol Etilico \n');
    cprintf('Text', '\t 4) Gel(Ultrasonico) \n');
    choice = convalidaInput(4);
    
    switch choice 
        
        case 1
            z = 1479036; % Rayl(Kg s^-1 m^-2)
            
        case 2
            z = 414.5; % Rayl(Kg s^-1 m^-2)
            
        case 3
            z = 972842; % Rayl(Kg s^-1 m^-2)
        
        case 4
            z = 1500000; % Rayl(Kg s^-1 m^-2)
    end

end