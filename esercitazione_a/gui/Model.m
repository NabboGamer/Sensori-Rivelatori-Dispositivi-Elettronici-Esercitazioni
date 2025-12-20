classdef Model < handle
    %MODEL Application data model.

    % Copyright 2021-2025 The MathWorks, Inc.

    properties
        App(:, 1)
        Simulazione(:, 1)
        Config
        CSVFile
        ResultText
        CurrentExercise string {mustBeScalarOrEmpty}
    end

    properties ( SetAccess = private )
        % Application data.
        PztProperties
        Data(:, 1) double = double.empty( 0, 1 )
    end % properties ( SetAccess = private )

    events ( NotifyAccess = private )
        % Event broadcast when the data is changed.
        DataChanged
    end % events ( NotifyAccess = private )

    methods

        function obj = Model()
            addpath("../core")
            obj.PztProperties = caricaStrutturaProprietaPzt();
            obj.Config = YamlParser.read(fullfile(fileparts(mfilename('fullpath')), 'config/config.yaml'));

            if ~isempty(obj.Config) && iscell(obj.Config) && isfield(obj.Config{1}, 'exercise')
                obj.CurrentExercise = obj.Config{1}.exercise;
            end
        end

        function simulate( obj )
            %SIMULATE Esegue una simulazione basata sul tipo selezionato.

            %% Geometria
            l = obj.App.TabController.getTab('CeramicsTab').getComponent('CampoSpessore').Value;
            ordineDiGrandezzal = calcolaOrdineDiGrandezza(l);

            forma = obj.App.TabController.getTab('CeramicsTab').getComponent('MenuForma').Value;
            switch forma
                case "Quadrato"
                    L = obj.App.TabController.getTab('CeramicsTab').getComponent('CampoParametro1').Value;
                    ordineDiGrandezzaL = calcolaOrdineDiGrandezza(L);
                    if (ordineDiGrandezzaL >= (ordineDiGrandezzal + 1))
                        areaFaccia = L * L;
                    else
                        obj.App.showError("Dimensioni non corrette per il modo thickness.");
                        return;
                    end
                case "Rettangolo"
                    L = obj.App.TabController.getTab('CeramicsTab').getComponent('CampoParametro1').Value;
                    w = obj.App.TabController.getTab('CeramicsTab').getComponent('CampoParametro2').Value;
                    ordineDiGrandezzaL = calcolaOrdineDiGrandezza(L);
                    ordineDiGrandezzaw = calcolaOrdineDiGrandezza(w);
                    if (ordineDiGrandezzaL >= (ordineDiGrandezzal + 1) && ...
                            ordineDiGrandezzaw >= (ordineDiGrandezzal + 1) && w < L)
                        areaFaccia = L * w;
                    else
                        obj.App.showError("Dimensioni non corrette per il modo thickness.");
                        return;
                    end
                case "Cerchio"
                    R = obj.App.TabController.getTab('CeramicsTab').getComponent('CampoParametro1').Value;
                    ordineDiGrandezzaR = calcolaOrdineDiGrandezza(R);
                    if (ordineDiGrandezzaR >= (ordineDiGrandezzal + 1))
                        areaFaccia = pi * (R^2);
                    else
                        obj.App.showError("Dimensioni non corrette per il modo thickness.");
                        return;
                    end
            end

            %% Pzt config
            try
                keyMap = containers.Map([obj.PztProperties{:,1}], obj.PztProperties(:,2));
                selezionePzt = obj.App.TabController.getTab('CeramicsTab').getComponent('MenuPz').Value;
                pztProps = keyMap(selezionePzt);
                rho = pztProps(1);
                c33 = pztProps(2);
                h33 = pztProps(3);
                e33 = pztProps(4);
                beta33 = h33/e33;
                v = sqrt(c33/rho);
                [f, omega] = calcolaIntervalliFrequenzeEPulsazioniDiRisonanza(v, l);
                theta = (omega .* l) ./ v;
                C0 = (areaFaccia/(beta33*l));
            catch
                fprintf('WARNING: Impossibile trovare il componente MenuPz in CeramicsTab. Le proprietà della ceramica non verranno impostate.');
            end
            %% Impedenze
            try
                mezziStandard = obj.App.TabController.getTab('ImpedenzeTab').getComponent('CheckMezziStandard').Value;
            catch
                mezziStandard = false;
            end

            %% Configurazione Specifica
            currentConfig = [];
            for i = 1:numel(obj.Config)
                if strcmp(obj.Config{i}.exercise, obj.CurrentExercise)
                    currentConfig = obj.Config{i};
                    break;
                end
            end

            if isempty(currentConfig)
                obj.App.showError("Configurazione non trovata per l'esercizio selezionato.");
                return;
            end

            %% Pipeline
            pipeline = currentConfig.pipeline;
            for j = 1:length(pipeline)
                cmd = pipeline{j};
                try
                    eval(cmd);
                catch ME
                    fprintf("Error executing pipeline command: %s\nError: %s\n", cmd, ME.message);
                    obj.App.showError("Pipeline Error: " + ME.message + newline + "Command: " + cmd);
                    rethrow(ME);
                end
            end

            %% Risultato (testuale)
            if isfield(currentConfig, 'resultText')
                resultText = currentConfig.resultText;
                try
                    obj.ResultText = eval(resultText);
                catch ME
                    fprintf('Errore nella valutazione del testo "%s": %s\n', resultText, ME.message);
                    obj.App.showError("Result-text Error: " + ME.message + newline + "Command: " + cmd);
                    return;
                end
                obj.ResultText = replace(obj.ResultText, '\n', newline);
                obj.ResultText = replace(obj.ResultText, '\t', '    ');
            end

            %% Esecuzione comandi di drawing per i plots
            if isfield(currentConfig, 'plots')
                plots = currentConfig.plots;
                validPlots = {};

                % Filtra i plots in base alle regole
                for i = 1:numel(plots)
                    plotConfig = plots{i};
                    isValid = true;

                    if isfield(plotConfig, 'rules')
                        rules = plotConfig.rules;
                        for k = 1:numel(rules)
                            rule = rules{k};
                            % Valuta la regola nel workspace corrente
                            try
                                ruleResult = eval(rule);
                                if ~ruleResult
                                    isValid = false;
                                    break;
                                end
                            catch ME
                                fprintf('Errore nella valutazione della regola "%s": %s\n', rule, ME.message);
                                isValid = false;
                                break;
                            end
                        end
                    end

                    if isValid
                        validPlots{end+1} = plotConfig;
                    end
                end

                % Aggiorna le tabs nella view con i plots filtrati
                obj.App.VistaGrafici.setupTabs(validPlots);

                % Disegna i plots validi
                for i = 1:numel(validPlots)
                    plotConfig = validPlots{i};

                    drawingCommands = plotConfig.drawing;

                    % Crea una figura tradizionale temporanea invisibile
                    % Questo è necessario perché stampaGrafici usa subplot che lavora su figure
                    tempFig = figure('Visible', 'off');

                    % Esegui ogni comando di drawing
                    for j = 1:numel(drawingCommands)
                        cmd = drawingCommands{j};
                        % Valuta il comando nel workspace corrente
                        try
                            eval(cmd);
                        catch ME
                            fprintf('Errore nella valutazione del comando (plotting)"%s": %s\n', cmd, ME.message);
                            obj.App.showError("Plotting Error: " + ME.message + newline + "Command: " + cmd);
                            rethrow(ME); % Removed to prevent app crash
                        end

                        % Aggiungi hold on tra i comandi per sovrapporre i grafici
                        if j < numel(drawingCommands)
                            hold on;
                        end
                    end

                    % Aggiorna la tab corrispondente usando il metodo di PlotView
                    obj.App.VistaGrafici.updatePlot(i, tempFig.Children);

                    % Chiudi la figura temporanea
                    close(tempFig);
                end

            end

            notify( obj, "DataChanged" )

        end % simulate

    end % methods

end % classdef