function realQuantity = realQuantityPicker(msg, stringQuantity)
    %REALQUANTITYPICKER permette di acquisire una generica quantità reale

    cprintf('Text',"\n");
    cprintf('Text', "%s", msg);
    
    string = sprintf("%s=", stringQuantity);
    inputString = input(string, "s");
    try
        realQuantity = str2double(inputString);
    catch
        realQuantity = NaN;
    end
   
    if (~isnumeric(realQuantity) || isinf(realQuantity) || isnan(realQuantity) || realQuantity <= 0)
        cprintf('Errors', "Il numero inserito non è valido, prego reinserire...\n");
        realQuantity = realQuantityPicker(msg, stringQuantity);
    end

end

