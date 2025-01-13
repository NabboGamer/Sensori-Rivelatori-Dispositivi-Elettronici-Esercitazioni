function [rho, c33, h33, e33, beta33, v] = elementPicker()
    % ELEMENTPICKER permette di acquisire le costanti dielettriche e alcuni parametri relativi ad una specifica ceramica piezoelettrica
    
    cprintf('Text',"\n");
    cprintf('Text', "Inserire il codice numerico associato alla ceramica piezoelettrica: ");
    var = input('pz=');
    
        switch var
    
            case 21
                rho = 7.78e+03; % Kg/m^3
                c33 = 1.11e+11; % N/m^2
                h33 = 1.34e+09; % V/m
                e33 = 23.4; % C/m^2
                
                %TODO: Verificare correttezza formula
                beta33 = h33/e33; % Vm/C
                
                v = sqrt(c33/rho); % m^2/sec
    
            case 23
                rho = 7.70e+03; % Kg/m^3
                c33 = 1.54e+11; % N/m^2
                h33 = 2.01e+09; % V/m
                e33 = 15.5; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            case 24
                rho = 7.70e+03; % Kg/m^3
                c33 = 1.81e+11; % N/m^2
                h33 = 4.70e+09; % V/m
                e33 = 9.9; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            case 26
                rho = 7.70e+03; % Kg/m^3
                c33 = 1.58e+11; % N/m^2
                h33 = 2.37e+09; % V/m
                e33 = 14.7; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            case 27
                rho = 7.70e+03; % Kg/m^3
                c33 = 1.44e+11; % N/m^2
                h33 = 1.98e+09; % V/m
                e33 = 16.0; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            case 28
                rho = 7.70e+03; % Kg/m^3
                c33 = 1.52e+11; % N/m^2
                h33 = 2.76e+09; % V/m
                e33 = 12.4; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            case 29
                rho = 7.46e+03; % Kg/m^3
                c33 = 1.51e+11; % N/m^2
                h33 = 1.96e+09; % V/m
                e33 = 21.2; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            case 34
                rho = 7.55e+03; % Kg/m^3
                c33 = 1.67e+11; % N/m^2
                h33 = 4.28e+09; % V/m
                e33 = 6.5; % C/m^2
    
                beta33 = h33/e33; % Vm/C
                v = sqrt(c33/rho); % m^2/sec
    
            otherwise
                cprintf('Errors', "Codice inesistente, prego reinserire...\n");
                [rho, c33, h33, e33, beta33, v] = elementPicker();
        end
        
end
        
    
       