function [areaFaccia, l, rho, c33, h33, e33, beta33, v, f, omega, theta, C0] = ceramicPicker()
    % CERAMICPICKER permette di acquisire tutti i parametri caratteristici di una specifica ceramica piezoelettrica di interesse per l'utente

    % Configurazione geometria dell'elemento, acquisizione di forma e dimensioni dell'elemento
    [areaFaccia, l] = geometryPicker();
 
    % Scelta tipo elemento piezoelettrico, acquisizione di tutti i parametri
    % caratteristici, indipendenti da forma e dimensione
    [rho, c33, h33, e33, beta33, v] = elementPicker();
    
    % Calcolo frequenza, pulsazione di risonanza e del range di frequenze e
    % pulsazioni d'interesse per l'elemento specifico
    [f, omega] = calcolaIntervalliFrequenzeEPulsazioniDiRisonanza(v,l);
    
    theta = (omega .* l) ./ v;

    %Calcolo capacità statica della ceramica
    C0 = (areaFaccia/(beta33*l)); % (m*C)/V

end