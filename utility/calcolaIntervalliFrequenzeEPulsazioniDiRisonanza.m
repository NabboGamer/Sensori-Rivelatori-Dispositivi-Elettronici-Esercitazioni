function [f, omega] = calcolaIntervalliFrequenzeEPulsazioniDiRisonanza(v, l)
    % CALCOLAINTERVALLIFREQUENZEEPULSAZIONIDIRISONANZA permette di calcolare gli intervalli di frequenze e pulsazioni di risonanza data la velocità di propagazione delle onde v e lo spessore l
    
    fr = v/(2*l); % Hz
    
    range = fr;
    
    f = (fr - range / 2) : 100 : (fr + range / 2);
    omega = 2*pi .* f; % rad/sec
    
end