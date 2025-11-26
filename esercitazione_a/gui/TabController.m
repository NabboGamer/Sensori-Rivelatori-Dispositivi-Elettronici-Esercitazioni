classdef TabController < Component
    %TABCONTROLLER Controller per la gestione delle schede
    %   Coordina le schede dell'interfaccia utente e applica le impostazioni

    properties
        App(:, 1)
    end

    properties ( GetAccess = public, SetAccess = private )
        TabFrequenza(:, 1)
        TabPlot(:, 1)
        TabRisultati(:, 1)
        TabCeramica(:, 1)
        GruppoTab(:, 1)
    end

    properties ( Access = private )
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end

    methods
        function obj = TabController( namedArgs )
            %TABCONTROLLER Costruisce un'istanza di questa classe
            %   Inizializza il controller delle schede

            arguments ( Input )
                namedArgs.?TabController
            end % arguments ( Input )

            % Chiama il costruttore della superclasse.
            obj@Component()

            % Imposta le proprietà specificate dall'utente.
            set( obj, namedArgs )

        end

        function set.App( obj, app )
            obj.App = app;
            if ~isempty(obj.TabCeramica)
                obj.TabCeramica.App = app;
            end
            if ~isempty(obj.TabFrequenza)
                obj.TabFrequenza.App = app;
            end
            if ~isempty(obj.TabPlot)
                obj.TabPlot.App = app;
            end
            if ~isempty(obj.TabRisultati)
                obj.TabRisultati.App = app;
            end

            if isempty(obj.Listener)
                obj.Listener = addlistener(obj.App.Modello, 'DataChanged', @obj.onDataChanged);
            end
        end

        function applySettings(obj, defaults)
            if isempty(defaults)
                return;
            end

            for i = 1:length(defaults)
                setting = defaults{i};
                if isfield(setting, 'kind')
                    switch setting.kind
                        case 'CeramicsTab'
                            if ~isempty(obj.TabCeramica)
                                obj.TabCeramica.applySettings(setting);
                            end
                        case 'FrequencyTab'
                            if ~isempty(obj.TabFrequenza)
                                obj.TabFrequenza.applySettings(setting);
                            end
                        case 'PlotTab'
                            if ~isempty(obj.TabPlot)
                                obj.TabPlot.applySettings(setting);
                            end
                    end
                end
            end
        end
    end

    methods ( Access = protected )

        function setup ( obj )
            grid = uigridlayout(obj);
            grid.RowHeight = "1x";
            grid.ColumnWidth = "1x";
            grid.Padding = 0;
            obj.GruppoTab = uitabgroup(grid);
            ceramicaTabContainer = uitab(obj.GruppoTab, "Title", "Ceramica");
            obj.TabCeramica = CeramicsTab("Parent", ceramicaTabContainer);
            frequenzaTabContainer = uitab(obj.GruppoTab, "Title", "Frequenza");
            obj.TabFrequenza = FrequencyTab("Parent", frequenzaTabContainer);
            plotTabContainer = uitab(obj.GruppoTab, "Title", "Grafici");
            obj.TabPlot = PlotTab("Parent", plotTabContainer);
            risultatiTabContainer = uitab(obj.GruppoTab, "Title", "Risultati");
            obj.TabRisultati = ResultTab("Parent", risultatiTabContainer);
        end

        function update( ~ )
        end % update

    end

    methods ( Access = private )
        function onDataChanged(obj, ~, ~)
            obj.GruppoTab.SelectedTab = obj.TabRisultati.Parent;
        end
    end
end