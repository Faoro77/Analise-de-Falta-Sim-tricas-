% Trabalho Computacional | Cálculo de Faltas Simétricas
% Analise de Potencias 2 | Prof. Dionatan Cieslak
% Gabriel Vizentin Faoro | RA: 2299640

%% Inicio do Codigo
clc; 
clear; 
close all;

%Frescura

fprintf('-------------------------------------------------------\n\n');
fprintf('    Análise de Faltas Simétricas de Gabriel Faoro\n');
fprintf('-------------------------------------------------------\n\n');

%% -------- Inserir os Dados da SEP --------------

% Número de barras e linhas
nb = 8;  % Numero de Barras
nl = 9;  % Numero de Linhas

% Tabela das Linhas de Transmissão [Barra de, Barra para, Xm(pu)] a ordem nao altera o resultado
linhas =  [
          %[m,n,Xm(pu)]
            2 5 0.2120;
            2 3 0.1611;
            1 2 0.1645;
            3 7 0.1304;
            4 8 0.1839;
            6 8 0.1828;
            7 8 0.1054;
            3 6 0.2524;
            5 8 0.2523;
                        ];

% Tabela de reatancias dos geradores  Xg (pu) colocar em ordem
% Usado "Inf"(é reatancia infinita) quando nao tem gerador na barra
            Xg = [
                  0.2690;  % Barra 1
                  0.1119;  % Barra 2
                  Inf;     % Barra 3
                  Inf;     % Barra 4
                  Inf;     % Barra 5
                  Inf;     % Barra 6
                  0.2594;  % Barra 7
                  Inf;     % Barra 8
                                    ];

%% ------------ Parte de inseiri dados acabou -----------                                    
                                    
% Tensões pré-falta em cada barra (pu, 1∠0)
Vpref = ones(nb,1);  

% Escolha interativa da barra de falta
bf = input('Informe a barra em falta (1 a n): '); % Input comando pra fazer a escolha da Barra
assert(ismember(bf,1:nb),'Barra inválida');       % Assert e o Ismember é para que sempre seja um valor valido

%% 1 Montagem da Matriz Ybus
Ybus = zeros(nb);
  for k = 1:nl
      m   = linhas(k,1);  % m equivale ao de
      n = linhas(k,2);    % n equivale ao para
      x    = linhas(k,3); % x equivale ao Xm
      y = 1/(1j*x);
      Ybus(m,m)     = Ybus(m,m) + y;
      Ybus(n,n) = Ybus(n,n) + y;
      Ybus(m,n)   = Ybus(m,n) - y;
      Ybus(n,m)   = Ybus(n,m) - y;
  end

% Adiciona reatâncias de geradores em cada barra
  for b = 1:nb
      if ~isinf(Xg(b))
          Ybus(b,b) = Ybus(b,b) + 1/(1j * Xg(b));
      end
  end
  
fprintf('Matriz Ybus (Matriz Admitância de Barra):\n');
disp(Ybus);
fprintf('\n');


%% 2 Cálculo da Matriz Zbus
Zbus = inv(Ybus);
fprintf('Matriz Zbus (Matriz Impedância de Barra):\n');
disp(Zbus);
fprintf('\n');

%% 3 Corrente de falta na barra de falta
If = Vpref(bf) / Zbus(bf, bf);
   fprintf('\nCorrente de falta na barra %d: %6.4f ∠%6.2f° pu\n', bf, abs(If), angle(If)*180/pi)
fprintf('\n');
    
%% 4 Tensões pós-falta em todas as barras
fprintf('\nTensões pós-falta (pu):\n');
fprintf('--------------------------\n\n');
V_posfalta = Vpref - Zbus(:,bf) * If;
   for b = 1:nb
       fprintf(' Barra %d: %6.4f ∠%6.2f°\n', b, abs(V_posfalta(b)), angle(V_posfalta(b))*180/pi);
   end


%% 5 Contribuição dos Geradores para a Corrente de Falta
fprintf('\nContribuições individuais dos geradores (corrente de saída de cada gerador) (pu):\n');
fprintf('-----------------------------------------------------------------------------------\n\n');

   for b = 1:nb 
       % Verifica se existe um gerador na barra
       if ~isinf(Xg(b))
  
           % Impedância do gerador
           Zg = 1j * Xg(b);
        
           % Calculo da corrente do gerador
           Ig = (Vpref(b) - V_posfalta(b)) / Zg;
        
           fprintf(' Gerador na barra %d: %6.4f ∠%6.2f° pu\n', b, abs(Ig), angle(Ig)*180/pi); %Resultado
       end
   end

%% 6 Correntes nas linhas conectadas a barra de falta
fprintf('\nCorrentes nas linhas conectadas à barra de falta (pu):\n');
fprintf('--------------------------------------------------------\n\n');
   for k = 1:nl
       m   = linhas(k,1);
       n   = linhas(k,2);
       x   = linhas(k,3);
       if m==bf || n==bf
           zlt = 1j*x;
           Ilt = (V_posfalta(m) - V_posfalta(n)) / zlt;
           fprintf(' Linha %d–%d: %6.4f ∠%6.2f° pu\n', m, n, abs(Ilt), angle(Ilt)*180/pi);
       end
   end

%---------- se acabou -----------------
