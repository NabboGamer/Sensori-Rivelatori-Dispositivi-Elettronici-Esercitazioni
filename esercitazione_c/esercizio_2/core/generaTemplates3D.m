function percorsoTemplates3D = generaTemplates3D(percorsoTemplates, sizeNeighboorhod)
    % GENERATEMPLATE3D si occupa di generare template 3D partendo dai template 2D salvati come template_*.mat
    % 
    % Struttura attesa:
    %   percorsoTemplates/
    %       templates_<denoising>_<enhancement>/
    %           utente1/
    %               acquisizione1/
    %                   template_0.mat  (contiene templateImg)
    %                   template_1.mat
    %                   ...
    % Output:
    %   percorsoTemplates/templates_<denoising>_<enhancement>_3d/
    %       utente1/acquisizione1/template_3d.mat, .jpg, _color.jpg

    if nargin < 2 || isempty(sizeNeighboorhod)
        sizeNeighboorhod = 3;
    end
    
    cprintf('Comments', "Elaborazione immagini iniziata...\n");
    cprintf('Comments', "\n");
    tStart = tic;

    % Cartella output    
    parts = split(string(percorsoTemplates), ["\" "/"]);
    parts(parts=="") = []; % elimina eventuali vuoti(es. separatore finale)
    percorsoPadreCartellaTemplates = join(parts(1:end-1), string(filesep));
    percorsoPadreCartellaTemplates = fullfile(percorsoPadreCartellaTemplates);
    nomeCartellaTemplates = parts(end);
    
    nomeCartellaTemplates3D = strcat(nomeCartellaTemplates, "_3d");
    percorsoTemplates3D = fullfile(percorsoPadreCartellaTemplates, nomeCartellaTemplates3D);
    creaCartella(percorsoTemplates3D);

    sottoCartelleUtenti = dir(percorsoTemplates);
    sottoCartelleUtenti = sottoCartelleUtenti([sottoCartelleUtenti.isdir]);
    sottoCartelleUtenti = sottoCartelleUtenti(~ismember({sottoCartelleUtenti.name}, {'.','..'}));
    for i = 1:numel(sottoCartelleUtenti)
        nomeUtente = string(sottoCartelleUtenti(i).name);
        percorsoUtente = fullfile(percorsoTemplates, nomeUtente);

        sottoCartelleAcq = dir(percorsoUtente);
        sottoCartelleAcq = sottoCartelleAcq([sottoCartelleAcq.isdir]);
        sottoCartelleAcq = sottoCartelleAcq(~ismember({sottoCartelleAcq.name}, {'.','..'}));
        for j = 1:numel(sottoCartelleAcq)
            nomeAcq = string(sottoCartelleAcq(j).name);
            percorsoAcq = fullfile(percorsoUtente, nomeAcq);
            
            [matriceZXY, sliceIds] = generaMatriceTemplates(percorsoAcq);
            if isempty(matriceZXY)
                continue;
            end

            filtraggio = filtraggioInProfondita(matriceZXY, sizeNeighboorhod);

            outAcq = fullfile(percorsoTemplates3D, nomeUtente, nomeAcq);
            creaCartella(outAcq);

            % nome base file
            baseName = "template_3d";
            calcolaMappaProfonditaTratti(filtraggio, outAcq, baseName, sliceIds);
        end
    end

    sec = toc(tStart);
    cprintf('Comments', "Elaborazione immagini terminata dopo %.3f secondi!\n", sec);
end
