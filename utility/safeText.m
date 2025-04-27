function safeText(ax, x, y, labelString, xOffset, yOffset)
    % SAFETEXT Scrive un testo nel grafico senza uscire fuori dai limiti. Si adatta automaticamente alla scala lineare o logaritmica degli assi.

    % Prendi limiti assi dallo specifico ax
    xlimits = xlim(ax);
    ylimits = ylim(ax);

    % Prendi scala assi
    xscale = get(ax, 'XScale');
    yscale = get(ax, 'YScale');

    % Calcola nuova posizione X
    if strcmp(xscale, 'log')
        x_new = 10^(log10(x) + xOffset);
    else
        x_new = x + xOffset;
    end

    % Calcola nuova posizione Y
    if strcmp(yscale, 'log')
        y_new = 10^(log10(y) + yOffset);
    else
        y_new = y + yOffset;
    end

    % Correggi se fuori da limiti X
    if x_new > xlimits(2)
        x_new = xlimits(2) * 0.98;
    elseif x_new < xlimits(1)
        x_new = xlimits(1) * 1.02;
    end

    % Correggi se fuori da limiti Y
    if y_new > ylimits(2)
        y_new = ylimits(2) * 0.95;
        disp('ciao')
    elseif y_new < ylimits(1)
        y_new = ylimits(1) * 1.02;
    end

    % Scrive il testo con clipping ON (per sicurezza)
    text(x_new, y_new, labelString, 'Clipping', 'on', 'VerticalAlignment','top');

end
