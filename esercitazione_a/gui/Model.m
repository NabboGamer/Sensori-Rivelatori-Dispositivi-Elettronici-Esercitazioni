classdef Model < handle
    %MODEL Application data model.

    % Copyright 2021-2025 The MathWorks, Inc.

    properties
        App(:, 1)
        Simulazione(:, 1)
        Config
        ResultText
    end

    properties ( SetAccess = private )
        % Application data.
        PztProperties
        Data(:, 1) double = double.empty( 0, 1 )
    end % properties ( SetAccess = private )

    events ( NotifyAccess = private )
        % Event broadcast when the data is changed.
        DataChanged
    end % events ( NotifyAccess = private )

    methods

        function obj = Model()
            addpath("../core")
            obj.PztProperties = caricaStrutturaProprietaPzt();
            obj.Config = YamlParser.read(fullfile(fileparts(mfilename('fullpath')), 'config.yaml'));
        end

        function simulate( obj )
            %SIMULATE Esegue una simulazione basata sul tipo selezionato.

            %% Geometria
            l = obj.App.TabController.TabCeramica.CampoSpessore.Value;
            ordineDiGrandezzal = calcolaOrdineDiGrandezza(l);

            forma = obj.App.TabController.TabCeramica.MenuForma.Value;
            switch forma
                case "Quadrato"
                    L = obj.App.TabController.TabCeramica.CampoParametro1.Value;
                    ordineDiGrandezzaL = calcolaOrdineDiGrandezza(L);
                    if (ordineDiGrandezzaL >= (ordineDiGrandezzal + 1))
                        areaFaccia = L * L;
                    else
                        obj.App.showError("Dimensioni non corrette per il modo thickness.");
                        return;
                    end
                case "Rettangolo"
                    L = obj.App.TabController.TabCeramica.CampoParametro1.Value;
                    w = obj.App.TabController.TabCeramica.CampoParametro2.Value;
                    ordineDiGrandezzaL = calcolaOrdineDiGrandezza(L);
                    ordineDiGrandezzaw = calcolaOrdineDiGrandezza(w);
                    if (ordineDiGrandezzaL >= (ordineDiGrandezzal + 1) && ...
                            ordineDiGrandezzaw >= (ordineDiGrandezzal + 1) && w < L)
                        areaFaccia = L * w;
                    else
                        obj.App.showError("Dimensioni non corrette per il modo thickness.");
                        return;
                    end
                case "Cerchio"
                    R = obj.App.TabController.TabCeramica.CampoParametro1.Value;
                    ordineDiGrandezzaR = calcolaOrdineDiGrandezza(R);
                    if (ordineDiGrandezzaR >= (ordineDiGrandezzal + 1))
                        areaFaccia = pi * (R^2);
                    else
                        obj.App.showError("Dimensioni non corrette per il modo thickness.");
                        return;
                    end
            end

            %% Pzt config
            keyMap = containers.Map([obj.PztProperties{:,1}], obj.PztProperties(:,2));
            selezionePzt = obj.App.TabController.TabCeramica.MenuPz.Value;
            pztProps = keyMap(selezionePzt);
            rho = pztProps(1);
            c33 = pztProps(2);
            h33 = pztProps(3);
            e33 = pztProps(4);
            beta33 = h33/e33;
            v = sqrt(c33/rho);
            [f, omega] = calcolaIntervalliFrequenzeEPulsazioniDiRisonanza(v, l);
            theta = (omega .* l) ./ v;
            C0 = (areaFaccia/(beta33*l));

            %% Pipeline
            pipeline = obj.Config{1}.pipeline;
            for j = 1:length(pipeline)
                cmd = pipeline{j};
                eval(cmd);
            end

            %% Risultato (testuale)
            if isfield(obj.Config{1}, 'resultText')
                obj.ResultText = eval(obj.Config{1}.resultText);
                obj.ResultText = replace(obj.ResultText, '\n', newline);
                obj.ResultText = replace(obj.ResultText, '\t', '    ');
            end

            notify( obj, "DataChanged" )

        end % simulate

    end % methods

end % classdef