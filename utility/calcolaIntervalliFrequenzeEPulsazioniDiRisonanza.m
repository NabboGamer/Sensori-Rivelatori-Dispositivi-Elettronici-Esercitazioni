function [f, omega] = calcolaIntervalliFrequenzeEPulsazioniDiRisonanza(v, l)
    % CALCOLAINTERVALLIFREQUENZEEPULSAZIONIDIRISONANZA permette di calcolare gli intervalli di frequenze e pulsazioni di risonanza data la velocità di propagazione delle onde v e lo spessore l
    
    fr = v/(2*l); % Hz
    
    f = linspace(fr - (fr / 4), fr + (fr / 4), 1000);
    omega = 2*pi .* f; % rad/sec
    
end