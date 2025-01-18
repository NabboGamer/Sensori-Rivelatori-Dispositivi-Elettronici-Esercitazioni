function numberOfCeramicPairs = numberOfCeramicPairsPicker()
    %NUMBEROFCERAMICPAIRSPICKER permette di acquisire il numero di coppie di cermiache piezoelettriche desiderate

    cprintf('Text',"\n");
    cprintf('Text', "Inserire il numero desiderato di coppie di ceramiche piezoelettriche(1 = 2 cer, 2 = 4 cer, 3 = 8 cer, etc...): ");
    numberOfCeramicPairs = input("numberOfCeramicPairs=");

    if (mod(numberOfCeramicPairs, 1) ~= 0 || numberOfCeramicPairs < 1)
        cprintf('Errors', "Il numero inserito non è intero o non è maggiore di 1, prego reinserire...\n");
        numberOfCeramicPairs = numberOfCeramicPairsPicker();
    end

end

