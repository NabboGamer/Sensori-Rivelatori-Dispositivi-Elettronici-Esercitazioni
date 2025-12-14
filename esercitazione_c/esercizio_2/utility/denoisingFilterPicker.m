function scelta = denoisingFilterPicker()
    %FILTERPICKER permette di scegliere un filtro di denoising/despeckling tra quelli disponibili

    % I filtri di denoising despeckling provano a ridurre la granulosità 
    % (speckle) preservando i dettagli delle immagini, usando strategie 
    % adattive (statistiche locali) come nel caso del Filtro di Lee o 
    % PDE/diffusione anisotropa come nel caso del filtro SRAD.
    cprintf('Text', "Selezionare un filtro di denoising/despeckling tra quelli disponibili: \n");
    cprintf('Text', '\t 1) Filtro di Lee \n');
    cprintf('Text', '\t 2) Filtro Speckle Reducing Anisotropic Diffusion (SRAD) \n');
    
    scelta = convalidaInput(2);
    if scelta == 1
        scelta = "lee";
    else
        scelta = "srad";
    end
    cprintf('Comments', "\n");
end