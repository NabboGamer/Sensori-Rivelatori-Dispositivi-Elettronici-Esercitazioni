function [rho, z, v] = preloadMassPicker()
    % PRELOADMASSPICKER permette di acquisire alcuni parametri relativi a una specifica massa di precarico

    cprintf('Text',"\n");
    cprintf('Text', "Seleziona il materiale della massa di precarico: \n");
    cprintf('Text', '\t 1) Alluminio \n');
    cprintf('Text', '\t 2) Carbonio \n');
    cprintf('Text', '\t 3) Ferro \n');
    cprintf('Text', '\t 4) Titanio \n');
    cprintf('Text', '\t 5) Zinco \n');
    choice = convalidaInput(5);
    
    switch choice 
        
        case 1
            rho = 2.7e+03;
            z   = 16.95e+06;
        
        case 2
            rho = 11e+03;
            z   = 74.8e+06;
        
        case 3
            rho = 7.9e+03;
            z   = 47e+06;
            
        case 4
            rho = 4.5e+03;
            z   = 27.2e+06;
        
        case 5
            rho = 7.1e+03;
            z   = 28.75e+06;
        
    end
    
    v = z/rho;
end


