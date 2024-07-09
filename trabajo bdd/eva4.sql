--Crear las tablas y sus respectivas secuencias

create sequence seq_cliente_id start with 1;

create table Cliente(
    id number default seq_cliente_id.nextval not null,
    rut varchar2(30) not null,
    apellidos varchar2(30) not null,
    telefono varchar2(30) not null,
    stateAt varchar2(1) default '0' check (stateAt in ('0','1')),
    createdAt timestamp default sysdate,
    updatedAt timestamp null,
    constraint pk_cliente_id primary key (id),
    constraint uk_cliente_rut unique (rut)
);

create sequence seq_equipo_id start with 1;

create table Equipo(
    id number default seq_equipo_id.nextval not null,
    marca varchar2(30) not null,
    modelo varchar2(30) not null,
    imei varchar2(30) not null,
    stateAt varchar2(1) default '0' check (stateAt in ('0','1')),
    createdAt timestamp default sysdate,
    updatedAt timestamp null,
    cliente_id number not null,
    constraint pk_equipo_id primary key (id),
    constraint fk_cliente_id foreign key (cliente_id) references Cliente(id)
);

create sequence seq_diagnostico_id start with 1;

create table Diagnostico(
    id number default seq_diagnostico_id.nextval not null,
    problema varchar2(30) not null,
    precioReparacion number not null,
    fechaHora timestamp not null,
    stateAt varchar2(1) default '0' check (stateAt in ('0','1')),
    createdAt timestamp default sysdate,
    updatedAt timestamp null,
    equipo_id number not null,
    tecnicoDiagnostico_id number not null,
    constraint pk_diagnostico_id primary key (id),
    constraint fk_equipo_id foreign key (equipo_id) references Equipo(id),
    constraint fk_tecnicoDiagnostico_id foreign key (tecnicoDiagnostico_id) references Tecnico(id)
);

CREATE SEQUENCE seq_tecnico_id START WITH 1;

CREATE TABLE Tecnico(
    id number default seq_tecnico_id.NEXTVAL NOT NULL,
    rut varchar2(20) NOT NULL,
    nombre varchar2(30) NOT NULL,
    apellidos varchar2(30) NOT NULL,
    usuario varchar2(30) NOT NULL,
    clave varchar2(80) NOT NULL,
    stateAt varchar2(1) default '0' CHECK (stateAt in('0', '1')),
    createdAt TIMESTAMP default sysdate,
    updatedAt TIMESTAMP NULL,
    CONSTRAINT pk_tecnico_id PRIMARY KEY (id)
);

CREATE SEQUENCE seq_solicitud_id START WITH 1;

CREATE TABLE Solicitud(
    id number default seq_solicitud_id.NEXTVAL NOT NULL,
    problema varchar2(200) NOT NULL,
    precioReparacion number NOT NULL,
    estadoSolicitud varchar2(30) NOT NULL,
    stateAt varchar2(1) default '0' CHECK (stateAt in('0', '1')),
    createdAt TIMESTAMP default sysdate,
    updatedAt TIMESTAMP NULL,
    equipo_id number not null,
    tecnicoAsignadoid number NOT NULL,
    constraint pk_solicitud_id PRIMARY KEY (id),
    constraint fk_equipoSolicitud_id foreign key (equipo_id) references Equipo(id),
    constraint fk_tecnicoAsignadoid foreign key (tecnicoAsignadoid) references Tecnico(id)
);

create sequence seq_log_id start with 1;

CREATE TABLE Log (
    id number,
    tabla varchar2(30),
    operacion varchar2(10),
    fechaHora timestamp,
    CONSTRAINT pk_log_id PRIMARY KEY (id)
);

--Crear los triggers

CREATE TRIGGER log_cliente
AFTER DELETE OR UPDATE ON Cliente
FOR EACH ROW
BEGIN
  INSERT INTO Log (id, tabla, operacion, fechaHora)
  VALUES (seq_log_id.nextval, 'Cliente', CASE WHEN DELETING THEN 'DELETE' ELSE 'UPDATE' END, SYSDATE);
END;

CREATE OR REPLACE TRIGGER actualizar_fecha
BEFORE UPDATE ON Equipo
FOR EACH ROW
BEGIN
  :NEW.updatedAt := SYSDATE;
END;

CREATE TRIGGER crear_solicitud
AFTER INSERT ON Diagnostico
FOR EACH ROW
BEGIN
  INSERT INTO Solicitud (problema, precioReparacion, estadoSolicitud, stateAt, createdAt, equipo_id, tecnicoAsignadoid)
  VALUES (:NEW.problema, :NEW.precioReparacion, 'en proceso', '0', SYSDATE, :NEW.equipo_id, :NEW.tecnicoDiagnostico_id);
END;
--crear los procedimientos

CREATE PROCEDURE agregar_registros (
    p_rutCliente IN Cliente.rut%TYPE,
    p_apellidos IN Cliente.apellidos%TYPE,
    p_telefono IN Cliente.telefono%TYPE,
    p_marca IN Equipo.marca%TYPE,
    p_modelo IN Equipo.modelo%TYPE,
    p_imei IN Equipo.imei%TYPE,
    p_problema IN Diagnostico.problema%TYPE,
    p_precioReparacion IN Diagnostico.precioReparacion%TYPE,
    p_nombreTecnico IN Tecnico.nombre%TYPE,
    p_rutTecnico IN Tecnico.rut%TYPE,
    p_apellidosTecnico IN Tecnico.apellidos%TYPE,
    p_usuarioTecnico IN Tecnico.usuario%TYPE,
    p_claveTecnico IN Tecnico.clave%TYPE
)
AS
v_idCliente Cliente.id%TYPE;
v_idEquipo Equipo.id%TYPE;
v_idDiagnostico Diagnostico.id%TYPE;
v_idTecnico Tecnico.id%TYPE;
BEGIN
  -- Insertar un registro en la tabla Cliente
  INSERT INTO Cliente (nombre, rut, apellidos, telefono, createdAt)
  VALUES (p_nombreCliente, p_rutCliente, p_apellidos, p_telefono, SYSDATE);

  -- Insertar un registro en la tabla Equipo
  INSERT INTO Equipo (marca, modelo, imei, createdAt, cliente_id)
  VALUES (p_marca, p_modelo, p_imei, SYSDATE, v_idCliente);

  -- Insertar un registro en la tabla Tecnico
  INSERT INTO Tecnico (rut, nombre, apellidos, usuario, clave)
  VALUES (p_rutTecnico, p_nombreTecnico, p_apellidosTecnico, p_usuarioTecnico, p_claveTecnico);

  -- Insertar un registro en la tabla Diagnostico
  INSERT INTO Diagnostico (problema, precioReparacion, fechaHora, createdAt, equipo_id, tecnicoDiagnostico_id)
  VALUES (p_problema, p_precioReparacion, SYSDATE, SYSDATE, v_idEquipo, v_idTecnico);
END;

CREATE PROCEDURE eliminar_registro (
    p_id IN Cliente.id%TYPE
)
AS
BEGIN
  -- Eliminar el registro de la tabla Cliente con el id indicado
  DELETE FROM Cliente
  WHERE id = p_id;
END;

CREATE PROCEDURE actualizar_registro (
    p_clienteId IN Cliente.id%TYPE,
    p_nombreCliente IN Cliente.nombre%TYPE,
    p_rutCliente IN Cliente.rut%TYPE,
    p_direccion IN Cliente.direccion%TYPE,
    p_telefono IN Cliente.telefono%TYPE
)
AS
BEGIN
  -- Actualizar el registro de la tabla Cliente con el id indicado
  UPDATE Cliente
  SET nombre = p_nombreCliente,
      rut = p_rutCliente,
      direccion = p_direccion,
      telefono = p_telefono,
      updatedAt = SYSDATE
  WHERE id = p_clienteId;
END;

-- Insertar un registros

EXECUTE agregar_registros (
    'Juan Perez',
    '12345678-9',
    'Av. Los Andes 123',
    '987654321',
    'Laptop',
    'HP',
    'Pavilion',
    'ABC123',
    'No enciende',
    50000,
    'Pedro Gomez',
    '87654321-0'
);

EXECUTE agregar_registros (
    'Ana Lopez',
    '23456789-0',
    'Av. Los Lagos 456',
    '876543210',
    'Celular',
    'Samsung',
    'Galaxy S20',
    'XYZ789',
    'Pantalla rota',
    30000,
    'Maria Rodriguez',
    '34567890-1'
);

EXECUTE agregar_registros (
    'Carlos Sanchez',
    '45678901-2',
    'Av. Los Rios 789',
    '765432109',
    'Tablet',
    'Apple',
    'iPad Air',
    'DEF456',
    'No carga batería',
    40000,
    'Jose Gonzalez',
    '56789012-3'
);

EXECUTE agregar_registros (
    'Luisa Fernandez',
    '67890123-4',
    'Av. Los Montes 1011',
    '654321098',
    'Impresora',
    'Epson',
    'L3150',
    'GHI789',
    'No imprime bien',
    20000,
    'Pedro Gomez',
    '87654321-0'
);

-- Funciones

CREATE FUNCTION aplicar_descuento (
    p_idDiagnostico IN Diagnostico.id%TYPE,
    p_porcentaje IN NUMBER
)
RETURN NUMBER
AS
  v_precio NUMBER;
  v_nuevoPrecio NUMBER;
BEGIN
  -- Consultar el precioReparacion del diagnóstico con el id dado
  SELECT precioReparacion INTO v_precio FROM Diagnostico WHERE id = p_idDiagnostico;
  -- Calcular el nuevo precio aplicando el descuento
  v_nuevoPrecio := v_precio * (1 - p_porcentaje / 100);
  -- Devolver el nuevo precio
  RETURN v_nuevoPrecio;
END;

-- Ejecutar la función desde un SELECT y pasarle el id de un diagnóstico y el porcentaje de descuento
SELECT aplicar_descuento(1, 10) AS nuevoPrecio FROM DUAL;

-- Views

CREATE VIEW diagnosticos_mayores AS
  SELECT id, problema, precioReparacion, equipo_id, tecnicoDiagnostico_id
  FROM Diagnostico
  WHERE precioReparacion > (SELECT AVG(precioReparacion) FROM Diagnostico);

SELECT * FROM diagnosticos_mayores;

CREATE VIEW equipos_clientes AS
  SELECT e.id, e.marca, e.modelo, e.imei, c.id, c.rut, c.nombre, c.apellidos, c.telefono
  FROM Equipo e
  INNER JOIN Cliente c ON e.id = c.id;

  SELECT * FROM equipos_clientes;