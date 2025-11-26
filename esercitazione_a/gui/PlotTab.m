classdef PlotTab < Component
    %PLOTTAB Vista per la configurazione dei grafici.

    properties
        App(:, 1) App {mustBeScalarOrEmpty}
    end

    properties ( GetAccess = public, SetAccess = private )
        Griglia(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}

        EtichettaGrafico1(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
        MenuGrafico1(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}

        CheckMostraSecondo(:, 1) matlab.ui.control.CheckBox {mustBeScalarOrEmpty}

        EtichettaGrafico2(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
        MenuGrafico2(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}
    end

    methods
        function obj = PlotTab( namedArgs )
            arguments ( Input )
                namedArgs.?PlotTab
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
                        if isfield(value, 'MenuGrafico1')
                            obj.MenuGrafico1.Value = value.MenuGrafico1;
                        end
                        if isfield(value, 'MenuGrafico2')
                            obj.MenuGrafico2.Value = value.MenuGrafico2;
                        end
                        if isfield(value, 'CheckMostraSecondo')
                            obj.CheckMostraSecondo.Value = value.CheckMostraSecondo;
                        end

                        if isfield(setting, 'disabled')
                            for j = 1:length(setting.disabled)
                                value = setting.disabled{j};
                                switch value
                                    case 'MenuGrafico1'
                                        obj.MenuGrafico1.Enable = 'off';
                                    case 'MenuGrafico2'
                                        obj.MenuGrafico2.Enable = 'off';
                                    case 'CheckMostraSecondo'
                                        obj.CheckMostraSecondo.Enable = 'off';
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
                "RowHeight", {'fit', 'fit', 'fit', '1x'}, ...
                "ColumnWidth", {'fit', '1x'} );

            % Grafico 1
            obj.EtichettaGrafico1 = uilabel( "Parent", obj.Griglia, "Text", "Grafico 1" );
            obj.MenuGrafico1 = uidropdown( "Parent", obj.Griglia, ...
                "Items", ["FTT", "FTR"] );

            % Checkbox Mostra Secondo
            etichettaMostraSecondo = uilabel( "Parent", obj.Griglia, "Text", "Mostra secondo grafico" );
            obj.CheckMostraSecondo = uicheckbox( "Parent", obj.Griglia, ...
                "Text", "", ...
                "Value", true, ...
                "ValueChangedFcn", @obj.onMostraSecondoChanged );

            % Grafico 2
            obj.EtichettaGrafico2 = uilabel( "Parent", obj.Griglia, "Text", "Grafico 2" );
            obj.MenuGrafico2 = uidropdown( "Parent", obj.Griglia, ...
                "Items", ["FTT", "FTR"] );

            % Inizializza la vista
            obj.onMostraSecondoChanged();
        end

        function update( obj )
        end
    end

    methods ( Access = private )
        function onMostraSecondoChanged( obj, ~, ~ )
            if obj.CheckMostraSecondo.Value
                obj.EtichettaGrafico2.Visible = "on";
                obj.MenuGrafico2.Visible = "on";
            else
                obj.EtichettaGrafico2.Visible = "off";
                obj.MenuGrafico2.Visible = "off";
            end

            if ~isempty(obj.App) && ~isempty(obj.App.VistaGrafici)
                obj.App.VistaGrafici.ToggleSecondPlot(obj.CheckMostraSecondo.Value);
                disp("Second plot %s\n", obj.CheckMostraSecondo.Value);
            end
        end
    end
end
