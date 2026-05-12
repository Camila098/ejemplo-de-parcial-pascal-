program programaparcial;

type
  fecha = record
    dia: 1..31;
    mes: 1..12;
    anio: integer;
  end;

  autor = record
    dni: longint;
    nombreApellido: string;
  end;

  obra = record
    titulo: string;
    codigo: string;
    material: string;
    f: fecha;
    estado: string;
    importancia: string;
    detalle: string;
  end;

  lista = ^nodoLista;
  nodoLista = record
    dato: obra;
    sig: lista;
  end;

  arbol = ^nodoarbol;
  nodoarbol = record
    au: autor;
    l: lista;
    cantObras: integer;
    HI, HD: arbol;
  end;

procedure cargarFecha(var f: fecha);
begin
  write('dia: '); readln(f.dia);
  write('mes: '); readln(f.mes);
  write('anio: '); readln(f.anio);
end;

procedure leerAutor(var au: autor);
begin
  write('Nombre y Apellido: '); readln(au.nombreApellido);
  write('DNI: '); readln(au.dni);
end;

procedure leerObra(var o: obra; var au: autor);
begin
  write('Ingrese el titulo de la obra (ULTIMA para finalizar): ');
  readln(o.titulo);
  if (o.titulo <> 'ULTIMA') then begin
    write('Codigo: '); readln(o.codigo);
    write('Material: '); readln(o.material);
    write('Estado: '); readln(o.estado);
    write('Importancia: '); readln(o.importancia);
    write('Detalle autor: '); readln(o.detalle);
    cargarFecha(o.f);
    leerAutor(au);
  end;
  writeln();
end;

procedure CargarlistaObras(var l: lista; o: obra);
var aux: lista;
begin
  new(aux);
  aux^.dato := o;
  aux^.sig := l;
  l := aux;
end;

procedure InsertarEnArbol(var a: arbol; o: obra; au: autor);
begin
  if (a = nil) then begin
    new(a);
    a^.au := au;
    a^.l := nil;
    CargarlistaObras(a^.l, o);
    a^.cantObras := 1;
    a^.HI := nil;
    a^.HD := nil;
  end
  else if (au.dni < a^.au.dni) then
    InsertarEnArbol(a^.HI, o, au)
  else if (au.dni > a^.au.dni) then
    InsertarEnArbol(a^.HD, o, au)
  else begin
    CargarlistaObras(a^.l, o);
    a^.cantObras := a^.cantObras + 1;
  end;
end;

procedure CargarArbol(var a: arbol);
var o: obra; au: autor;
begin
  a := nil;
  leerObra(o, au);
  while (o.titulo <> 'ULTIMA') do begin
    InsertarEnArbol(a, o, au);
    leerObra(o, au);
  end;
end;

{ --- b) Porcentaje --- }

procedure calcularEnLista(l: lista; var cumplen: integer);
begin
  while (l <> nil) do begin
    if (l^.dato.importancia = 'historica') and (l^.dato.estado = 'preventiva') then begin
      if (l^.dato.f.anio > 1850) or ((l^.dato.f.anio = 1850) and (l^.dato.f.mes >= 3)) then
        if (l^.dato.f.anio < 1950) or ((l^.dato.f.anio = 1950) and (l^.dato.f.mes <= 7)) then
          cumplen := cumplen + 1;
    end;
    l := l^.sig;
  end;
end;

procedure busquedaCompleta(a: arbol; var total, cumplen: integer);
begin
  if (a <> nil) then begin
    busquedaCompleta(a^.HI, total, cumplen);
    total := total + a^.cantObras;
    calcularEnLista(a^.l, cumplen);
    busquedaCompleta(a^.HD, total, cumplen);
  end;
end;

function porcentaje(a: arbol): real;
var totalObras, cumplen: integer;
begin
  totalObras := 0; cumplen := 0;
  busquedaCompleta(a, totalObras, cumplen);
  if (totalObras > 0) then
    porcentaje := (cumplen * 100) / totalObras
  else
    porcentaje := 0;
end;

{ --- c) Rango de DNI --- }

procedure BuscarEnRango(a: arbol; inf, sup: longint);
begin
  if (a <> nil) then begin
    if (a^.au.dni >= inf) then begin
      if (a^.au.dni <= sup) then begin
        BuscarEnRango(a^.HI, inf, sup);
        writeln('Autor: ', a^.au.nombreApellido, ' | Obras: ', a^.cantObras);
        BuscarEnRango(a^.HD, inf, sup);
      end
      else
        BuscarEnRango(a^.HI, inf, sup);
    end
    else
      BuscarEnRango(a^.HD, inf, sup);
  end;
end;

{ --- d) Eliminar autor con más obras en madera --- }

procedure MaxEnLista(l: lista; var cant: integer);
begin
  while (l <> nil) do begin
    if (l^.dato.material = 'madera') then cant := cant + 1;
    l := l^.sig;
  end;
end;

procedure calcularMaximo(a: arbol; var max: integer; var dni: longint);
var cantMadera: integer;
begin
  if (a <> nil) then begin
    cantMadera := 0;
    MaxEnLista(a^.l, cantMadera);
    if (cantMadera > max) then begin
      max := cantMadera;
      dni := a^.au.dni;
    end;
    calcularMaximo(a^.HI, max, dni);
    calcularMaximo(a^.HD, max, dni);
  end;
end;

function obtenerNodoMinimo(a: arbol): arbol;
begin
  if (a^.HI = nil) then obtenerNodoMinimo := a
  else obtenerNodoMinimo := obtenerNodoMinimo(a^.HI);
end;

procedure borrarNodo(var a: arbol; dni: longint);
var aux: arbol;
begin
  if (a <> nil) then begin
    if (dni < a^.au.dni) then borrarNodo(a^.HI, dni)
    else if (dni > a^.au.dni) then borrarNodo(a^.HD, dni)
    else begin { Nodo encontrado }
      if (a^.HI = nil) then begin
        aux := a; a := a^.HD; dispose(aux);
      end
      else if (a^.HD = nil) then begin
        aux := a; a := a^.HI; dispose(aux);
      end
      else begin { Dos hijos }
        aux := obtenerNodoMinimo(a^.HD);
        a^.au := aux^.au;
        a^.l := aux^.l;
        a^.cantObras := aux^.cantObras;
        borrarNodo(a^.HD, aux^.au.dni);
      end;
    end;
  end;
end;

{ Procedimientos de impresión para mostrar cambios }
procedure ImprimirEstructura(a: arbol);
begin
  if (a <> nil) then begin
    ImprimirEstructura(a^.HI);
    writeln('DNI: ', a^.au.dni, ' - Autor: ', a^.au.nombreApellido);
    ImprimirEstructura(a^.HD);
  end;
end;

procedure liberarLista(var l: lista);
var
  aux: lista;
begin
  while (l <> nil) do begin
    aux := l;
    l := l^.sig;
    dispose(aux);
  end;
end;

{ modulo recursivo para borrar todo el arbol }
procedure liberarArbol(var a: arbol);
begin
  if (a <> nil) then begin
    { 1. Limpiar subárboles primero (recorrido post-orden) }
    liberarArbol(a^.HI);
    liberarArbol(a^.HD);

    { 2. Antes de borrar el nodo del árbol, vaciamos su lista interna }
    liberarLista(a^.l);

    { 3. Finalmente borramos el nodo del autor }
    dispose(a);
    a := nil; { Seteamos a nil para evitar punteros basura }
  end;
end;

var
  a: arbol;
  maxMadera: integer;
  dniMax: longint;
begin
  CargarArbol(a);
  writeln();

  writeln(' Porcentaje de obras que sean de importancia historica, con estado de conservacion preventiva y creadas entre Marzo de 1850 y Julio de 1950: ');
  writeln('Porcentaje: ', porcentaje(a):2:2, '%');
  writeln();

  writeln('cantidad de obras de aquellos autores que posean numero de documento entre 30000000 y 50000000');
  BuscarEnRango(a, 30000000, 50000000);
  writeln();

  writeln(' busqueda y eliminacion de la estructura al autor que posee mas obras realizadas en madera');
  writeln('Estructura antes:');
  ImprimirEstructura(a);
  writeln();

  maxMadera := 0; dniMax := -1;
  calcularMaximo(a, maxMadera, dniMax);
  if (dniMax <> -1) then begin
    borrarNodo(a, dniMax);
    writeln('Se elimino al autor con DNI: ', dniMax);
  end;

  writeln();
  writeln('Estructura despues:');
  ImprimirEstructura(a);

  writeln();
  writeln('Liberando memoria...');
  liberarArbol(a);

  if (a = nil) then
    writeln('Memoria liberada correctamente.');

  readln();
end.
