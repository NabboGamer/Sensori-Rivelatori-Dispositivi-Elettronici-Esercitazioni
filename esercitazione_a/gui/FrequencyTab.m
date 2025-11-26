classdef FrequencyTab < Component
    %FREQUENCYTAB Vista per la selezione della frequenza.

    properties
        App(:, 1) App {mustBeScalarOrEmpty}
    end

    properties ( GetAccess = public, SetAccess = private )
        Griglia(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        MenuUnita(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}
        UnitaEstremi(1, 1) string

        Start(:, 1) matlab.ui.control.NumericEditField {mustBeScalarOrEmpty}
        UnitaStart(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}

        Stop(:, 1) matlab.ui.control.NumericEditField {mustBeScalarOrEmpty}
        UnitaStop(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
    end

    methods
        function obj = FrequencyTab( namedArgs )
            arguments ( Input )
                namedArgs.?FrequencyTab
            end
            obj@Component()
            set( obj, namedArgs )
        end

        function applySettings(obj, settings)
            if isempty(settings)
                return;
            end

            for i = 1:length(settings)
                setting = settings;
                if isfield(setting, 'values')
                    for j = 1:length(setting.values)
                        value = setting.values;
                        if isfield(value, 'UnitaEstremi')
                            obj.UnitaEstremi = value.UnitaEstremi;
                            obj.UnitaStart.Text = obj.UnitaEstremi;
                            obj.UnitaStop.Text = obj.UnitaEstremi;
                        end
                        if isfield(value, 'Start')
                            obj.Start.Value = value.Start;
                        end
                        if isfield(value, 'Stop')
                            obj.Stop.Value = value.Stop;
                        end
                        if isfield(setting, 'disabled')
                            for j = 1:length(setting.disabled)
                                value = setting.disabled{j};
                                switch value
                                    case 'UnitaEstremi'
                                        obj.UnitaEstremi.Enable = 'off';
                                    case 'Start'
                                        obj.Start.Enable = 'off';
                                    case 'Stop'
                                        obj.Stop.Enable = 'off';
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    methods ( Access = protected )
        function setup( obj )
            obj.Griglia = uigridlayout( "Parent", obj, ...
                "RowHeight", {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'}, ...
                "ColumnWidth", {'fit', '1x', 'fit'} );

            % Selettore Unità
            uilabel( "Parent", obj.Griglia, "Text", "Unità" );
            obj.MenuUnita = uidropdown( "Parent", obj.Griglia, ...
                "Items", ["kHz", "MHz"], ...
                "ValueChangedFcn", @obj.onCambioUnita );
            obj.MenuUnita.Layout.Column = [2 3];

            % Start
            uilabel( "Parent", obj.Griglia, "Text", "Start" );
            obj.Start = uieditfield( "numeric", "Parent", obj.Griglia );
            obj.UnitaStart = uilabel( "Parent", obj.Griglia, "Text", obj.UnitaEstremi );

            % Stop
            uilabel( "Parent", obj.Griglia, "Text", "Stop" );
            obj.Stop = uieditfield( "numeric", "Parent", obj.Griglia );
            obj.UnitaStop = uilabel( "Parent", obj.Griglia, "Text", obj.UnitaEstremi );

            % Inizializza la vista
            obj.onCambioUnita();
        end

        function update( obj )
        end
    end

    methods ( Access = private )
        function onCambioUnita( obj, ~, ~ )
            obj.UnitaEstremi = obj.MenuUnita.Value;
            obj.UnitaStart.Text = obj.UnitaEstremi;
            obj.UnitaStop.Text = obj.UnitaEstremi;
        end
    end
end
