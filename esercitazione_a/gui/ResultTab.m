classdef ResultTab < handle
    %ResultTab Vista per la visualizzazione dei risultati.

    properties
        App(:, 1) App {mustBeScalarOrEmpty}
    end

    properties ( GetAccess = public, SetAccess = private )
        Griglia(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        EtichettaRisultato(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
        Parent(:, 1) matlab.ui.container.Tab {mustBeScalarOrEmpty}
    end

    properties ( Access = private )
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end % properties ( Access = private )


    methods
        function Subscribe( obj )
            if ~isempty(obj.App) && ~isempty(obj.App.Modello)
                obj.Listener = listener( obj.App.Modello, ...
                    "DataChanged", ...
                    @obj.onDataChanged );

                onDataChanged( obj, [], [] )
            end
        end

        function obj = ResultTab( parent )
            obj.Parent = parent;
            % Create grid directly on the parent (uitab)
            obj.Griglia = uigridlayout( "Parent", parent, ...
                "RowHeight", {'fit'}, ...
                "ColumnWidth", {'fit'}, ...
                "Scrollable", "on" );

            obj.EtichettaRisultato = uilabel( "Parent", obj.Griglia, ...
                "Text", "Nessun risultato prodotto.", ...
                "WordWrap", "on");
        end

        function set.App( obj, app )
            obj.App = app;
            obj.Subscribe();
        end
    end

    methods ( Access = private )
        function update( obj )
            if ~isempty(obj.App) && ~isempty(obj.App.Modello) && ~isempty(obj.App.Modello.ResultText)
                obj.EtichettaRisultato.Text = obj.App.Modello.ResultText;
            end
        end

        function onDataChanged( obj, ~, ~ )
            obj.update();
        end % onDataChanged
    end
end
