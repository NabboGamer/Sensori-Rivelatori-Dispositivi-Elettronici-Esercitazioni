function [areaFaccia, l] = geometryPicker()
    %GEOMETRYPICKER permette di configurare a piacimento la geometria dell'elemento restituendo l'area della faccia e lo spessore

    cprintf('Text', "Selezionare la forma dell'oggetto tra quelle disponibili: \n");
    cprintf('Text', '\t 1) Quadrato \n');
    cprintf('Text', '\t 2) Rettangolo \n');
    cprintf('Text', '\t 3) Cerchio \n');
    
    choice = convalidaInput(3);
    
    switch choice
        case 1
            cprintf('Text', "Inserire la misura desiderata per il lato(m): ");
            L = input('L=');
            cprintf('Text', "Inserire la misura desiderata per lo spessore(m): ");
            l = input('l=');
            
            ordineDiGrandezzaL = calcolaOrdineDiGrandezza(L);
            ordineDiGrandezzal = calcolaOrdineDiGrandezza(l);
            
            if (ordineDiGrandezzaL >= (ordineDiGrandezzal + 1))
                areaFaccia = (L*L);
            else
                cprintf('Errors',"Dimensioni non corrette per il modo tickness, prego reinserire geometria...\n");
                cprintf('Errors',"\n");
                [areaFaccia, l] = geometryPicker();
            end
    
        case 2
            cprintf('Text', "Inserire la misura desiderata per la base(m): ");
            L = input('L=');
            cprintf('Text', "Inserire la misura desiderata per l'altezza(m): ");
            w = input('w=');
            cprintf('Text', "Inserire la misura desiderata per lo spessore(m): ");
            l = input('l=');
            
            ordineDiGrandezzaL = calcolaOrdineDiGrandezza(L);
            ordineDiGrandezzaw = calcolaOrdineDiGrandezza(w);
            ordineDiGrandezzal = calcolaOrdineDiGrandezza(l);

            if (ordineDiGrandezzaL >= (ordineDiGrandezzal + 1) && ...
                ordineDiGrandezzaw >= (ordineDiGrandezzal + 1) && w < L)
                areaFaccia = L*w;
            else
                cprintf('Errors',"Dimensioni non corrette per il modo tickness, prego reinserire geometria...\n");
                cprintf('Errors',"\n");
                [areaFaccia, l] = geometryPicker();
            end
    
        case 3
            cprintf('Text', "Inserire la misura desiderata per il raggio(m): ");
            R = input('R=');
            cprintf('Text', "Inserire la misura desiderata per lo spessore(m): ");
            l = input('l=');
            
            ordineDiGrandezzaR = calcolaOrdineDiGrandezza(R);
            ordineDiGrandezzal = calcolaOrdineDiGrandezza(l);

            if (ordineDiGrandezzaR >= (ordineDiGrandezzal + 1))
                areaFaccia = pi * (R^2);
            else
                cprintf('Errors',"Dimensioni non corrette per il modo tickness, prego reinserire geometria...\n");
                cprintf('Errors',"\n");
                [areaFaccia, l] = geometryPicker();
            end
    end

end
      