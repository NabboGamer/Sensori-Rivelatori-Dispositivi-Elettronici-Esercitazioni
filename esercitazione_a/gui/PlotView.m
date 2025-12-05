classdef PlotView < Component
    %VIEW Visualizes the data, responding to any relevant model events.

    % Copyright 2021-2025 The MathWorks, Inc.

    properties
        App(:,1) App
    end % properties

    properties ( SetAccess = private )
        TabGroup(:, 1) matlab.ui.container.TabGroup {mustBeScalarOrEmpty}
        Tabs(:, 1) cell = {}
        Panel(:, 1) matlab.ui.container.Panel {mustBeScalarOrEmpty}
    end % properties ( SetAccess = private )

    properties ( Access = private )
        % Listener object used to respond dynamically to model events.
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function Subscribe( obj )
            % Create weak reference to avoid circular reference
            weakObj = matlab.lang.WeakReference( obj );

            obj.Listener = listener( obj.App.Modello, ...
                "DataChanged", ...
                @( s, e ) weakObj.Handle.onDataChanged( s, e ) );

            % Inizializza le tabs con l'esercizio attualmente selezionato
            if ~isempty(obj.App.Controller) && ~isempty(obj.App.Controller.DropDownMenu)
                currentExercise = obj.App.Controller.DropDownMenu.Value;
                obj.initializeTabs(currentExercise);
            end

            % Refresh the view.
            onDataChanged( obj, [], [] )

        end

        function initializeTabs(obj, exerciseName)
            %INITIALIZETABS Inizializza le tab basandosi sul nome dell'esercizio

            % Pulisci le tab esistenti
            delete(obj.TabGroup.Children);
            obj.Tabs = {};

            % Trova la configurazione per l'esercizio specificato
            config = obj.App.Modello.Config;
            foundConfig = [];

            for i = 1:numel(config)
                if strcmp(config{i}.exercise, exerciseName)
                    foundConfig = config{i};
                    break;
                end
            end

            if isempty(foundConfig) || ~isfield(foundConfig, 'plots')
                return;
            end

            % Crea le nuove tab
            obj.createTabs(foundConfig.plots);
        end

        function updatePlot(obj, index, figureChildren)
            %UPDATEPLOT Updates the specified tab with new plot content.

            if index > numel(obj.Tabs) || index < 1
                return;
            end

            currentTab = obj.Tabs{index};

            % Pulisci la tab prima di disegnare
            delete(currentTab.Children);

            % Copia il contenuto della figura temporanea nella tab
            copyobj(figureChildren, currentTab);
        end

        function obj = PlotView( namedArgs )
            %VIEW View constructor.

            arguments ( Input )
                namedArgs.?PlotView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@Component()

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the view.

            % Crea il panel con bordo arrotondato
            obj.Panel = uipanel( ...
                "Parent", obj, ...
                "BorderType", "line", ...
                "BorderWidth", 2, ...
                "BackgroundColor", [1 1 1]);

            % Crea il TabGroup all'interno del panel
            obj.TabGroup = uitabgroup(obj.Panel, ...
                "Units", "normalized", ...
                "Position", [0 0 1 1]);

        end % setup

        function update( obj )
            %UPDATE Update the view in response to changes in the public
            %properties.



        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onDataChanged( obj, ~, ~ )
            %ONDATACHANGED Listener callback, responding to the model event
            %"DataChanged".

            % I comandi di drawing vengono eseguiti in Model.simulate
            % dove tutte le variabili sono disponibili

        end % onDataChanged

        function createTabs( obj, plots )
            %CREATETABS Crea dinamicamente le tabs basandosi sulla configurazione passata

            % Crea una tab per ciascun elemento in plots
            for i = 1:numel(plots)
                plotConfig = plots{i};

                % Crea la tab con il nome specificato
                tab = uitab(obj.TabGroup, "Title", plotConfig.name);
                obj.Tabs{end+1} = tab;
            end

        end % createTabs

    end % methods ( Access = private )

end % classdef