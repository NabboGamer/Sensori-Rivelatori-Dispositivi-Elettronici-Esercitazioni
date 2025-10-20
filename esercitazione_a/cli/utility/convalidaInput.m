function scelta = convalidaInput(maxNumberOfChoice)

    while true
        inputString = input('Scelta-> ', 's');
        try
            scelta = str2double(inputString);
        catch
            cprintf('Text','Scelta non valida. Riprovare... \n');
            continue;
        end
        if isfinite(scelta) && scelta > 0 && scelta < (maxNumberOfChoice+1) && scelta == round(scelta)
            scelta = round(scelta);
            break;
        else
            cprintf('Text','Scelta non valida. Riprovare... \n');
        end
    end
    
end

