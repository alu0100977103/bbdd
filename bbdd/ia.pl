:- chr_constraint info/3, marcada/2, obtener_info/3, obtener_casilla/3, esta_marcada/2.


% obtener_info/3 obtiene las dimensiones del tablero y el numero de minas.

% Unifica todos los parametros de una constraint obtener_info/3 con los parametros del unico constraint info/3.
info(Filas1, Columnas1, NumeroMinas1) \ obtener_info(Filas2, Columnas2, NumeroMinas2) <=> Filas1 = Filas2, Columnas1 = Columnas2, NumeroMinas1 = NumeroMinas2.


% Comprueba si se han abierto todas las casillas sin minas (ha ganado).
info(Filas, Columnas, NumeroMinas), casillas_abiertas(N) ==> M is (Filas*Columnas)-NumeroMinas, N =:= M | write('Has ganado!'), halt.


% obtener_casilla/3 obtiene el texto de una casilla determinada por su fila y columna en el tablero.

% Si existe en el store un field/3 y un obtener_casilla/3 cuyos parametros fila y columna coincidan, y ademas, 
% ese mismo obtener_casilla/3 tenga una variable como tercer parametro, entonces crear una constraint obtener_casilla/3 
% cuyo tercer parametro sea el texto de la casilla (ej: '1') o espacio en blanco en caso de ser 0 el numero de minas.
field(Fila, Columna, NumeroMinas1), obtener_casilla(Fila, Columna, NumeroMinas2) ==> var(NumeroMinas2) | 
  (
    % esta_marcada(Fila, Columna), TextoCasilla = 'M'
  % ;
    (
      NumeroMinas1 = 0,
      TextoCasilla = ' '
    ;
      NumeroMinas1 =\= 0,
      TextoCasilla = NumeroMinas1
    )
  ),
  obtener_casilla(Fila, Columna, TextoCasilla).

% Unifica el numero de minas (texto de la casilla) de dos constraint obtener_casilla/3 cuyas fila y columna coincidan.
obtener_casilla(Fila, Columna, NumeroMinas1), obtener_casilla(Fila, Columna, NumeroMinas2) <=> var(NumeroMinas1) | NumeroMinas1 = NumeroMinas2.

% En caso de que siga existiendo una constraint obtener_casilla/3 cuyo tercer parametro sea una variable (no esté instanciado) 
% significa que no existe una constraint field/3 con esa fila y columna, por tanto se establece el texto de la casilla a '.'.
obtener_casilla(Fila, Columna, NumeroMinas) ==> var(NumeroMinas) | obtener_casilla(Fila, Columna, '.').


% Unifica todos los parametros de una constraint esta_marcada/2 con los parametros de la constraint marcada/2.
marcada(Fila1, Columna1) \ esta_marcada(Fila2, Columna2) <=> Fila1 = Fila2, Columna1 = Columna2.

% TODO
esta_marcada(_, _) <=> fail.


% Elimina marcada/2 cuando hay dos iguales.
% Con esto conseguimos que cuando el usuario marque una casilla ya marcada, la desmarque.
marcada(X,Y), marcada(X,Y) <=> true.

% Elimina marcada/2 cuando está fuera del limite del tablero.
info(Xmax,Ymax,_) \ marcada(X,Y) <=> X < 1; Y < 1; X > Xmax; Y > Ymax | true.

% Elimina marcada/2 cuando se abre la casilla marcada.
field(X, Y, _) \ marcada(X, Y) <=> true.


main :-
  %trace,
  request_info(X,Y,Mines),
  info(X,Y,Mines),
  minesweeper(X,Y),
  mines(Mines),
  print_store,
  prompt.


% Debug info
print_store :- 
  write('--- DEBUG ---'), nl,
  chr_show_store(minesweeper),
  write('--- DEBUG END ---'), nl.


prompt :-
  used_time(Seconds),
  write('[Current Field - '), write(Seconds), write(' Seconds]'), nl,
  % Mostrar tablero
  mostrar_tablero, nl,
  elegir_opcion,
  print_store,
  prompt.


elegir_opcion :-
  write('[A = abrir casilla, M = marcar casilla, P = pedir una pista, F = finalizar]'), nl,
  write('Seleccione una opcion (A|M|P): '), read(Opcion),
  opcion(Opcion).


opcion('a') :- opcion('A').
opcion('A') :-
  write('[Abrir casilla]'), nl,
  write('  Fila:    '), read(X),
  write('  Columna: '), read(Y), nl,
  check(X,Y).
opcion('m') :- opcion('M').
opcion('M') :-
  write('[Marcar casilla]'), nl,
  write('  Fila:    '), read(X),
  write('  Columna: '), read(Y), nl,
  marcada(X,Y).
opcion('p') :- opcion('P').
opcion('P') :-
  write('[Opcion no implementada todavia]'), nl.
opcion('f') :- opcion('F').
opcion('F') :-
  write('[Opcion no implementada todavia, finaliza el buscaminas y lo resuelve automáticamente.]'), nl.
opcion(O) :-
  write(O), write(' no es una opcion valida.'), nl,
  elegir_opcion.


used_time(Seconds) :-
  start_time(Start),
  get_time(Now),
  Seconds is round(Now - Start).


request_info(X,Y,Mines) :-
  write('[Initialization]'), nl,
  write('  Numer of Rows:     '),
  read(X),
  write('  Number of Columns: '),
  read(Y),
  write('  Number of Mines:   '),
  read(Mines),
  get_time(StartTime),
  asserta(start_time(StartTime)).


mostrar_tablero :-
  obtener_info(Filas, Columnas, _),
  atom_length(Filas, AnchoFila),
  atom_length(Columnas, AnchoColumna),
  pintar_cabecera(Columnas, AnchoColumna),
  pintar_separador(Columnas, AnchoColumna),
  pintar_filas(Filas, Columnas, AnchoFila, AnchoColumna),
  pintar_separador(Columnas, AnchoColumna),
  pintar_cabecera(Columnas, AnchoColumna).


% Pinta la cabecera del tablero.
pintar_cabecera(Columnas, AnchoColumna) :-
  repetir(' ', AnchoColumna+2),
  write('| '),
  pintar_cabecera(1, Columnas, AnchoColumna),
  write('|'),
  repetir(' ', AnchoColumna+2), nl.
pintar_cabecera(Columna, Columnas, AnchoColumna) :-
  Columna =< Columnas, Columna >= 1,
  formatear_texto(Columna, AnchoColumna),
  write(' '),
  (Columna = Columnas;
  M is Columna+1,
  pintar_cabecera(M, Columnas, AnchoColumna)).


% Pinta un separador para el tablero.
pintar_separador(Columnas, AnchoColumna) :-
  repetir('-', AnchoColumna+2),
  write('+'),
  Ancho is Columnas*(AnchoColumna+1)+1,
  repetir('-', Ancho),
  write('+'),
  repetir('-', AnchoColumna+2), nl.


% Pinta las casillas del tablero.
pintar_filas(Filas, Columnas, AnchoFila, AnchoColumna) :- pintar_filas(1, Filas, Columnas, AnchoFila, AnchoColumna).
pintar_filas(Fila, Filas, Columnas, AnchoFila, AnchoColumna) :-
  Fila =< Filas, Fila >= 1,
  write(' '),
  formatear_texto(Fila, AnchoColumna),
  write(' | '),
  pintar_casillas(Fila, Columnas, AnchoColumna),
  write('| '),
  formatear_texto(Fila, AnchoColumna),
  write(' '), nl,
  (Fila =:= Filas;
  M is Fila + 1,
  pintar_filas(M, Filas, Columnas, AnchoFila, AnchoColumna)).


% Pinta las casillas de una fila.
pintar_casillas(Fila, Columnas, AnchoColumna) :- pintar_casillas(1, Fila, Columnas, AnchoColumna).
pintar_casillas(Columna, Fila, Columnas, AnchoColumna) :-
  Columna =< Columnas, Columna >= 1,
  obtener_casilla(Fila, Columna, Casilla),
  formatear_texto(Casilla, AnchoColumna),
  write(' '),
  (Columna =:= Columnas;
  M is Columna + 1,
  pintar_casillas(M, Fila, Columnas, AnchoColumna)).


% Repite un texto N veces.
repetir(_,0).
repetir(Texto,N) :-
  N > 0, M is N-1,
  write(Texto),
  repetir(Texto,M).

% Escribe un texto en un espacio con un ancho especificado, rellenando con espacios a la izquierda.
formatear_texto(Texto,Ancho) :-
  atom_length(Texto,AnchoTexto),
  NumeroEspacios is Ancho-AnchoTexto,
  repetir(' ',NumeroEspacios),
  write(Texto).
