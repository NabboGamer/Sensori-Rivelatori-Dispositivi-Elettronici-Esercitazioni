classdef PlotView < Component
    %VIEW Visualizes the data, responding to any relevant model events.

    % Copyright 2021-2025 The MathWorks, Inc.

    properties
        App(:,1) App
        % Line width.
        LineWidth(1, 1) double {mustBePositive, mustBeFinite} = 1.5
        % Line color.
        LineColor {validatecolor} = "k"
    end % properties

    properties ( GetAccess = ?Testable, SetAccess = private )
        Grid(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        Axes1(:, 1) matlab.ui.control.UIAxes {mustBeScalarOrEmpty}
        Axes2(:, 1) matlab.ui.control.UIAxes {mustBeScalarOrEmpty}
        % Line object used to visualize the model data.
        Line(:, 1) matlab.graphics.primitive.Line {mustBeScalarOrEmpty}
        Line2(:, 1) matlab.graphics.primitive.Line {mustBeScalarOrEmpty}
    end % properties ( GetAccess = ?Testable, SetAccess = private )

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


            % Refresh the view.
            onDataChanged( obj, [], [] )

        end

        function ToggleSecondPlot( obj, show )
            if show
                obj.Grid.RowHeight = {'1x', '1x'};
                obj.Axes2.Visible = 'on';
            else
                obj.Grid.RowHeight = {'1x', 0};
                obj.Axes2.Visible = 'off';
            end
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

            obj.Grid = uigridlayout(obj, [2 1]);
            obj.Grid.RowHeight = {'1x', '1x'};
            obj.Grid.Padding = 0;
            obj.Grid.RowSpacing = 0;

            % Create the view graphics.
            obj.Axes1 = uiaxes( "Parent", obj.Grid );
            obj.Axes2 = uiaxes( "Parent", obj.Grid );

            obj.Line = line( ...
                "Parent", obj.Axes1, ...
                "XData", NaN, ...
                "YData", NaN, ...
                "Color", obj.Axes1.ColorOrder(1, :), ...
                "LineWidth", 1.5 );

            obj.Line2 = line( ...
                "Parent", obj.Axes2, ...
                "XData", NaN, ...
                "YData", NaN, ...
                "Color", obj.Axes2.ColorOrder(2, :), ...
                "LineWidth", 1.5 );

            obj.Axes1.Color = 'white';
            obj.Axes2.Color = 'white';

        end % setup

        function update( obj )
            %UPDATE Update the view in response to changes in the public
            %properties.

            set( obj.Line, "LineWidth", obj.LineWidth, ...
                "Color", obj.LineColor )
            set( obj.Line2, "LineWidth", obj.LineWidth, ...
                "Color", obj.LineColor )

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onDataChanged( obj, ~, ~ )
            %ONDATACHANGED Listener callback, responding to the model event
            %"DataChanged".

            % Retrieve the most recent data and update the line.
            data = obj.App.Modello.Data;
            set( obj.Line, "XData", 1:numel( data ), "YData", data )
            set( obj.Line2, "XData", 1:numel( data ), "YData", data ) % Placeholder logic for second plot

        end % onDataChanged

    end % methods ( Access = private )

end % classdef