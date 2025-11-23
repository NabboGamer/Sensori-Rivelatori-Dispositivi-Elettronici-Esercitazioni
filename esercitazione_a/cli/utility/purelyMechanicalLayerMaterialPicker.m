function [rho, z, v] = purelyMechanicalLayerMaterialPicker(string)
    % PURELYMECHANICALLAYERMATERIALPICKER permette di acquisire parametri specifici relativi a una serie di materiali impiegati nella produzione di strati puramente meccanici

    % I seguenti valori sono stati prelevati dal pdf "Acoustic Properties of Solids, Onda Corporation"

    % Come suggerito nel pdf "Anatomy of Multiple Element Transducers",
    % per fare in modo che l'energia generata dalla ceramica sia diretta
    % verso destra(cioè verso il carico) la "backing mass" ovvero le masse
    % di precarico dovrebbero avere una impedenza acustica maggiore degli
    % della "front mass" ovvero degli strati meccanici che compone il 
    % concentratore.

    % Come suggerito nel pdf "What is the Right Material for
    % Making Ultrasonic Horns" i materiali più adatti da utilizzare per il
    % concentratore sono Alluminio e Titanio(tra l'altro il titanio è anche 
    % il materiale suggerito nelle dispense).
    % Di conseguenza i materiali più adatti da utilizzare per le masse di
    % precarico sono Acciaio, Ferro e Tungesteno.

    cprintf('Text',"\n");
    cprintf('Text', "%s: \n", string);
    cprintf('Text', '\t 1) Acciaio inossidabile 347 \n');
    cprintf('Text', '\t 2) Alluminio 6262-T9 \n');
    cprintf('Text', '\t 3) Ferro \n');
    cprintf('Text', '\t 4) Titanio \n');
    cprintf('Text', '\t 5) Tungsteno \n');
    choice = convalidaInput(5);
    
    switch choice 
        
        case 1
            v   = 5.9e+03;  % m/s
            rho = 7.89e+03; % Kg/m^3
            z   = 45.7e+06; % Rayl(Kg*s^-1*m^-2)

        case 2
            v   = 6.38e+03;
            rho = 2.73e+03;
            z   = 17.41e+06;
        
        case 3
            v   = 5.9e+03;
            rho = 7.69e+03;
            z   = 46.4e+06;
        
        case 4
            v   = 6.1e+03;
            rho = 4.48e+03;
            z   = 27.3e+06;
            
        case 5
            v   = 5.2e+03;
            rho = 19.4e+03;
            z   = 101.0e+06;
        
    end
    
end


