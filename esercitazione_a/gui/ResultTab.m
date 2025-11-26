classdef ResultTab < Component
    %ResultTab Vista per la visualizzazione dei risultati.

    properties
        App(:, 1) App {mustBeScalarOrEmpty}
    end

    properties ( GetAccess = public, SetAccess = private )
        Griglia(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        EtichettaRisultato(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
    end

    properties ( Access = private )
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end % properties ( Access = private )


    methods
        function Subscribe( obj )

            obj.Listener = listener( obj.App.Modello, ...
                "DataChanged", ...
                @obj.onDataChanged );

            onDataChanged( obj, [], [] )

        end

        function obj = ResultTab( namedArgs )
            arguments ( Input )
                namedArgs.?ResultTab
            end
            obj@Component()
            set( obj, namedArgs )
        end
    end

    methods ( Access = protected )
        function setup( obj )
            obj.Griglia = uigridlayout( "Parent", obj, ...
                "RowHeight", {'fit'}, ...
                "ColumnWidth", {'1x'} );

            obj.EtichettaRisultato = uilabel( "Parent", obj.Griglia, ...
                "Text", "Nessun risultato prodotto.", ...
                "WordWrap", "on");

        end

        function update( obj )
            if ~isempty(obj.App) && ~isempty(obj.App.Modello) && ~isempty(obj.App.Modello.ResultText)
                obj.EtichettaRisultato.Text = obj.App.Modello.ResultText;
            end
        end
    end

    methods ( Access = private )
        function onDataChanged( obj, ~, ~ )
            obj.update();
        end % onDataChanged
    end
end
