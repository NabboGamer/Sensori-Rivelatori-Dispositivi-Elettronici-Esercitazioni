classdef CeramicsTab < Component
    %CERAMICSTAB Vista per la selezione della forma della ceramica.

    properties
        App(:, 1) App {mustBeScalarOrEmpty}
    end

    properties ( GetAccess = public, SetAccess = private )
        Griglia(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        MenuForma(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}

        EtichettaParametro1(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
        CampoParametro1(:, 1) matlab.ui.control.NumericEditField {mustBeScalarOrEmpty}
        UnitaParametro1(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}

        EtichettaParametro2(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
        CampoParametro2(:, 1) matlab.ui.control.NumericEditField {mustBeScalarOrEmpty}
        UnitaParametro2(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}

        CampoSpessore(:, 1) matlab.ui.control.NumericEditField {mustBeScalarOrEmpty}
        UnitaSpessore(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}

        MenuZ1(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}
        MenuZ2(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}
        MenuPz(:, 1) matlab.ui.control.DropDown {mustBeScalarOrEmpty}
    end

    methods
        function obj = CeramicsTab( namedArgs )
            arguments ( Input )
                namedArgs.?CeramicsTab
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
                        if isfield(value, 'MenuForma')
                            obj.MenuForma.Value = value.MenuForma;
                            switch value.MenuForma
                                case 'Quadrato'
                                    obj.EtichettaParametro1.Text = 'Lato';
                                case 'Rettangolo'
                                    obj.EtichettaParametro1.Text = 'Base';
                                    obj.EtichettaParametro2.Text = 'Altezza';
                                case 'Cerchio'
                                    obj.EtichettaParametro1.Text = 'Raggio';
                            end
                        end
                        if isfield(value, 'CampoParametro1')
                            obj.CampoParametro1.Value = value.CampoParametro1;
                        end
                        if isfield(value, 'CampoParametro2')
                            obj.CampoParametro2.Value = value.CampoParametro2;
                        end
                        if isfield(value, 'CampoSpessore')
                            obj.CampoSpessore.Value = value.CampoSpessore;
                        end
                        if isfield(value, 'MenuZ1')
                            obj.MenuZ1.Value = value.MenuZ1;
                        end
                        if isfield(value, 'MenuZ2')
                            obj.MenuZ2.Value = value.MenuZ2;
                        end
                        if isfield(value, 'MenuPz')
                            obj.MenuPz.Value = value.MenuPz;
                        end
                    end
                end
                if isfield(setting, 'disabled')
                    for j = 1:length(setting.disabled)
                        value = setting.disabled{j};
                        switch value
                            case 'CampoSpessore'
                                obj.CampoSpessore.Enable = 'off';
                            case 'MenuZ1'
                                obj.MenuZ1.Enable = 'off';
                            case 'MenuZ2'
                                obj.MenuZ2.Enable = 'off';
                            case 'MenuPz'
                                obj.MenuPz.Enable = 'off';
                        end
                    end
                end
            end
        end
    end

    methods ( Access = protected )
        function setup( obj )
            obj.Griglia = uigridlayout( "Parent", obj, ...
                "RowHeight", {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'}, ...
                "ColumnWidth", {'fit', '1x', 'fit'} );

            % Selettore Forma
            uilabel( "Parent", obj.Griglia, "Text", "Forma" );
            obj.MenuForma = uidropdown( "Parent", obj.Griglia, ...
                "Items", ["Quadrato", "Rettangolo", "Cerchio"], ...
                "ValueChangedFcn", @obj.onCambioForma );
            obj.MenuForma.Layout.Column = [2 3];

            % Parametro 1
            obj.EtichettaParametro1 = uilabel( "Parent", obj.Griglia, "Text", "Lato" );
            obj.CampoParametro1 = uieditfield( "numeric", "Parent", obj.Griglia );
            obj.UnitaParametro1 = uilabel( "Parent", obj.Griglia, "Text", "m" );

            % Parametro 2
            obj.EtichettaParametro2 = uilabel( "Parent", obj.Griglia, "Text", "Altezza" );
            obj.CampoParametro2 = uieditfield( "numeric", "Parent", obj.Griglia );
            obj.UnitaParametro2 = uilabel( "Parent", obj.Griglia, "Text", "m" );

            % Spessore
            etichettaSpessore = uilabel( "Parent", obj.Griglia, "Text", "Spessore" );
            obj.CampoSpessore = uieditfield( "numeric", "Parent", obj.Griglia );
            obj.UnitaSpessore = uilabel( "Parent", obj.Griglia, "Text", "m" );

            % Z1
            etichettaZ1 = uilabel("Parent", obj.Griglia, "Text", "z1");
            etichettaZ1.Layout.Row = 5;
            etichettaZ1.Layout.Column = 1;
            obj.MenuZ1 = uidropdown("Parent", obj.Griglia, "Items", ["Aria (20°C)", "Acqua (20°C)", "Alcol Etilico", "Gel (Ultrasonico)"]);
            obj.MenuZ1.Layout.Row = 5;
            obj.MenuZ1.Layout.Column = [2 3];

            % Z2
            etichettaZ2 = uilabel("Parent", obj.Griglia, "Text", "z2");
            etichettaZ2.Layout.Row = 6;
            etichettaZ2.Layout.Column = 1;
            obj.MenuZ2 = uidropdown("Parent", obj.Griglia, "Items", ["Aria (20°C)", "Acqua (20°C)", "Alcol Etilico", "Gel (Ultrasonico)"]);
            obj.MenuZ2.Layout.Row = 6;
            obj.MenuZ2.Layout.Column = [2 3];

            % Pz
            etichettaPz = uilabel("Parent", obj.Griglia, "Text", "Tipo PZT");
            etichettaPz.Layout.Row = 7;
            etichettaPz.Layout.Column = 1;
            obj.MenuPz = uidropdown("Parent", obj.Griglia, "Items", ["Pz21", "Pz23", "Pz24", "Pz26", "Pz27", "Pz28", "Pz29", "Pz34"]);
            obj.MenuPz.Layout.Row = 7;
            obj.MenuPz.Layout.Column = [2 3];

            % Inizializza la vista
            obj.onCambioForma();
        end

        function update( obj )
        end

    end

    methods ( Access = private )
        function onCambioForma( obj, ~, ~ )
            switch obj.MenuForma.Value
                case "Quadrato"
                    obj.EtichettaParametro1.Text = "Lato";
                    obj.UnitaParametro1.Text = "m";
                    obj.EtichettaParametro1.Visible = "on";
                    obj.CampoParametro1.Visible = "on";
                    obj.UnitaParametro1.Visible = "on";

                    obj.EtichettaParametro2.Visible = "off";
                    obj.CampoParametro2.Visible = "off";
                    obj.UnitaParametro2.Visible = "off";

                case "Rettangolo"
                    obj.EtichettaParametro1.Text = "Base";
                    obj.UnitaParametro1.Text = "m";
                    obj.EtichettaParametro1.Visible = "on";
                    obj.CampoParametro1.Visible = "on";
                    obj.UnitaParametro1.Visible = "on";

                    obj.EtichettaParametro2.Text = "Altezza";
                    obj.UnitaParametro2.Text = "m";
                    obj.EtichettaParametro2.Visible = "on";
                    obj.CampoParametro2.Visible = "on";
                    obj.UnitaParametro2.Visible = "on";

                case "Cerchio"
                    obj.EtichettaParametro1.Text = "Raggio";
                    obj.UnitaParametro1.Text = "m";
                    obj.EtichettaParametro1.Visible = "on";
                    obj.CampoParametro1.Visible = "on";
                    obj.UnitaParametro1.Visible = "on";

                    obj.EtichettaParametro2.Visible = "off";
                    obj.CampoParametro2.Visible = "off";
                    obj.UnitaParametro2.Visible = "off";
            end
        end
    end
end
