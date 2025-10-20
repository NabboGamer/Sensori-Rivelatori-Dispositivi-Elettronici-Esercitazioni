function safeText(ax, x, y, labelString, xOffFrac, yOffFrac, varargin)
    % SAFETEXT Scrive un testo nel grafico senza uscire fuori dai limiti. Si adatta automaticamente alla scala lineare o logaritmica degli assi.
    % xOffFrac, yOffFrac sono frazioni dello span (es. 0.02 = 2%)

    % Limiti
    xl = xlim(ax); yl = ylim(ax);
    isXlog = strcmp(get(ax,'XScale'),'log');
    isYlog = strcmp(get(ax,'YScale'),'log');

    % Trasformo nel dominio dell'asse
    if isXlog, X = log10(x); XL = log10(xl); else, X = x;  XL = xl;  end
    if isYlog, Y = log10(y); YL = log10(yl); else, Y = y;  YL = yl;  end

    % Applico offset come frazione dello span
    X = X + xOffFrac*(XL(2)-XL(1));
    Y = Y + yOffFrac*(YL(2)-YL(1));

    % Clamping con margine 2% nello stesso dominio
    m = 0.02;
    X = min(max(X, XL(1)+m*(XL(2)-XL(1))), XL(2)-m*(XL(2)-XL(1)));
    Y = min(max(Y, YL(1)+m*(YL(2)-YL(1))), YL(2)-m*(YL(2)-YL(1)));

    % Ritorno alle unità dati
    if isXlog, x_new = 10.^X; else, x_new = X; end
    if isYlog, y_new = 10.^Y; else, y_new = Y; end

    % Allineamento coerente col segno dell'offset
    if xOffFrac > 0, ha = 'left'; elseif xOffFrac < 0, ha = 'right'; else, ha = 'center'; end
    if yOffFrac > 0, va = 'bottom'; elseif yOffFrac < 0, va = 'top'; else, va = 'middle'; end

    if ~isscalar(x_new) || ~isscalar(y_new)
        x_new = x_new(1); y_new = y_new(1);
    end

    text(ax, x_new, y_new, labelString, 'Clipping', 'on', ...
         'HorizontalAlignment', ha, 'VerticalAlignment', va, varargin{:});
end
