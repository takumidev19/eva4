create sequence seq_cliente_id start with 1;

create table Cliente(
    id number default seq_cliente_id.nextval not null,
    rut varchar2(30) not null,
    apellidos varchar2(30) not null,
    telefono varchar2(30) not null,
    stateAt varchar2(1) default '0' check (stateAt in ('0','1')),
    createAt timestamp default sysdate,
    updateAt timestamp null,
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
    createAt timestamp default sysdate,
    updateAt timestamp null,
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
    createAt timestamp default sysdate,
    updateAt timestamp null,
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
    updatedAt TIMESTAMP NULL
    equipo_id number not null,
    tecnicoAsignadoid number NOT NULL,
    constraint pk_solicitud_id PRIMARY KEY (id),
    constraint fk_equipo_id foreign key (equipo_id) references Equipo(id),
    constraint fk_tecnicoAsignadoid foreign key (tecnicoAsignadoid) references Tecnico(id)
);