function stampaLargezzaDiBanda(ax, xl, yl, xh, yh, color)
    %DISEGNALARGEZZADIBANDA permette di rappresentare in maniera chiara la largezza di banda di una funzione in ingresso

    % Applica ora l'autoscaling del grafico(altrimenti viene applicato dopo e le linee risultano troppo corte)
    drawnow;

    ylims = ylim(ax);
    xlims = xlim(ax);

    y_min = ylims(1);
    x_min = xlims(1);
    
    line(ax, [xl xl], [y_min yl], 'LineStyle', '--', 'LineWidth', 1, 'Color', color, 'Clipping', 'on', 'HandleVisibility', 'off');
    line(ax, [xh xh], [y_min yh], 'LineStyle', '--', 'LineWidth', 1, 'Color', color, 'Clipping', 'on', 'HandleVisibility', 'off');
    line(ax, [x_min xh], [yh yh], 'LineStyle', '--', 'LineWidth', 1, 'Color', color, 'Clipping', 'on', 'HandleVisibility', 'off');

end