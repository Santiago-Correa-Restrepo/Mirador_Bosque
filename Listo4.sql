create database BD_Mirador;

GO

use BD_Mirador;

GO

create table Permisos (
	IdPermiso int primary key identity(1,1),
	NomPermiso varchar(50)
);

create table Roles (
	IdRol int primary key identity(1,1),
	NomRol varchar(20),
	Estado bit,
);

create table PermisosRoles (
	IdPermisosRoles int primary key identity(1,1),
	IdRol int,
	IdPermiso int,
	foreign key (IdRol) references Roles(IdRol),
	foreign key (IdPermiso) references Permisos(IdPermiso)
);

create table Imagenes (
	IdImagen int primary key identity(1,1),
	UrlImagen nvarchar(max)
);

create table Usuarios (

	NroDocumento int primary key,
	IdTipoDocumento int,
	Nombres varchar(50),
	Apellidos varchar(50),
	Celular varchar(10),
	Correo varchar(100),
	Contrasena varchar(200),
	Estado BIT NOT NULL DEFAULT 1, -- 1: Activo, 0: Inactivo
	IdRol int,

	foreign key (IdRol) references Roles(IdRol)

);

create table TipoHabitaciones(
	IdTipoHabitacion int primary key identity(1,1),
	NomTipoHabitacion varchar(20),
	NumeroPersonas int,
	Estado bit NOT NULL default 1, -- 1: Disponible, 0: Ocupada
);

CREATE TABLE Habitaciones (
    IdHabitacion int primary key identity(1,1),
    Nombre varchar(50) NOT NULL,
    IdTipoHabitacion int NOT NULL, -- Relación con TipoHabitaciones
    Descripcion varchar (255),
	Cantidad int,
	FechaRegistro datetime NOT NULL default getdate(),
    Precio decimal(10, 2) NOT NULL,
	Estado bit NOT NULL default 1, -- 1: Disponible, 0: Ocupada
    foreign key (IdTipoHabitacion) references TipoHabitaciones(IdTipoHabitacion)
);

CREATE TABLE Muebles (
    IdMueble int primary key identity(1,1),
    Nombre varchar(100) NOT NULL,
	FechaRegistro datetime NOT NULL default getdate(),
	Valor decimal(10, 2),
    Estado bit NOT NULL default 1, -- 1: Activo, 0: Inactivo
    Imagen varbinary(max)
);

CREATE TABLE HabitacionMueble (
    IdHabitacionMueble int primary key identity(1,1),
    IdHabitacion int NOT NULL, -- Relación con Habitaciones
    IdMueble int NOT NULL, -- Relación con Muebles
    Cantidad int NOT NULL, -- Cantidad de muebles por habitación
    foreign key (IdHabitacion) references Habitaciones(IdHabitacion),
    foreign key (IdMueble) references Muebles(IdMueble)
);



create table ImagenHabitacion(
	IdImagenHabi int primary key identity(1,1),
	IdImagen int NOT NULL,
	IdHabitacion int NOT NULL,

	foreign key (IdImagen) references Imagenes(IdImagen),
	foreign key (IdHabitacion) references Habitaciones(IdHabitacion)
);

create table TipoServicios(
	IdTipoServicio int primary key identity(1,1),
	NombreTipoServicio varchar(50)  NOT NULL
);

create table Servicios(
	IdServicio int primary key identity(1,1),
	IdTipoServicio int  NOT NULL,
	NomServicio varchar(50) NOT NULL,
	Precio Decimal  NOT NULL,
	Descripcion varchar(50) NOT NULL,
	Estado BIT NOT NULL DEFAULT 1, -- 1: Disponible, 0: Ocupada

	foreign key (IdTipoServicio) references TipoServicios(IdTipoServicio)
);

create table ImagenServicio(
	IdImagenServi int primary key identity(1,1),
	IdImagen int NOT NULL,
	IdServicio int NOT NULL,

	foreign key (IdImagen) references Imagenes(IdImagen),
	foreign key (IdServicio) references Servicios(IdServicio)
);

create table Paquetes(
	IdPaquete int primary key identity(1,1),
	NomPaquete varchar(50)  NOT NULL,
	Precio Decimal  NOT NULL,
	IdHabitacion int  NOT NULL,
	Estado BIT NOT NULL DEFAULT 1, -- 1: Disponible, 0: Ocupada
	Descripcion varchar(200) NOT NULL,

	foreign key (IdHabitacion) references Habitaciones (IdHabitacion)

);

create table ImagenPaquete(
	IdImagenPaque int primary key identity(1,1),
	IdImagen int NOT NULL ,
	IdPaquete int NOT NULL,

	foreign key (IdImagen) references Imagenes(IdImagen),
	foreign key (IdPaquete) references Paquetes(IdPaquete)
);

create table PaqueteServicio(
	IdPaqueteServicio int primary key identity(1,1),
	IdPaquete int NOT NULL,
	IdServicio int NOT NULL,
	Precio Decimal NOT NULL,

	foreign key (IdPaquete) references Paquetes(IdPaquete),
	foreign key (IdServicio) references Servicios(IdServicio)
);

create table TipoDocumento(
	IdTipoDocumento int primary key identity(1,1) NOT NULL,
	NomTipoDcumento varchar(50) NOT NULL,
);

create table Clientes(

	NroDocumento int primary key not null,
	IdTipoDocumento int NOT NULL,
	Nombres varchar(50) NOT NULL,
	Apellidos varchar(50) NOT NULL,
	Celular varchar(10) NOT NULL,
	Correo varchar(100) NOT NULL,
	Contrasena varchar(200) NOT NULL,
	Estado BIT NOT NULL DEFAULT 1, -- 1: Activo, 0: Inactivo
	IdRol int,

	foreign key (IdRol) references Roles(IdRol),
	foreign key (IdTipoDocumento) references TipoDocumento(IdTipoDocumento)
);

create table MetodoPago(
	IdMetodoPago int primary key identity(1,1),
	NomMetodoPago varchar(20) NOT NULL
);

create table EstadosReserva(
	IdEstadoReserva int primary key identity(1,1),
	NombreEstadoReserva varchar(15) NOT NULL
);

create table Reservas(
	IdReserva int primary key identity(1,1),
	NroDocumentoCliente int NOT NULL,
	NroDocumentoUsuario int NOT NULL,
	FechaReserva datetime default getdate() NOT NULL,
	FechaInicio datetime NOT NULL,
	FechaFinalizacion datetime NOT NULL,
	SubTotal float NOT NULL,
	Descuento float NOT NULL,
	IVA float NOT NULL,
	MontoTotal float NOT NULL,
	MetodoPago int NOT NULL,
	NroPersonas int NOT NULL,
	IdEstadoReserva int NOT NULL,

	foreign key (NroDocumentoCliente) references Clientes(NroDocumento),
	foreign key (NroDocumentoUsuario) references Usuarios(NroDocumento),
	foreign key (IdEstadoReserva) references EstadosReserva(IdEstadoReserva),
	foreign key (MetodoPago) references MetodoPago(IdMetodoPago)
);


create table DetalleReservaServicio (
	IdDetalleReservaServicio int primary key identity(1,1),
	IdServicio int NOT NULL,
	IdReserva int NOT NULL,
	Cantidad int NOT NULL,
	Precio float NOT NULL,

	foreign key (IdServicio) references Servicios(IdServicio),
	foreign key (IdReserva) references Reservas(IdReserva)
);


create table DetalleReservaPaquete (
	DetalleReservaPaquete int primary key identity(1,1),
	IdPaquete int NOT NULL,
	IdReserva int NOT NULL,
	Cantidad int NOT NULL,
	Precio float NOT NULL,

	foreign key (IdPaquete) references Paquetes(IdPaquete),
	foreign key (IdReserva) references Reservas(IdReserva)
);

create table Abono(
	IdAbono int primary key identity(1,1),
	IdReserva int NOT NULL,
	FechaAbono datetime default getdate() NOT NULL,
	ValorDeuda float NOT NULL,
	Porcentaje float NOT NULL,
	Pendiente float NOT NULL,
	SubTotal float NOT NULL,
	IVA float NOT NULL,
	CantAbono float NOT NULL,
	Estado BIT NOT NULL DEFAULT 1, -- 1: Disponible, 0: Ocupada


	foreign key (IdReserva) references Reservas(IdReserva)
);

create table ImagenAbono(
	IdImagenAbono int primary key identity(1,1),
	IdImagen int NOT NULL,
	IdAbono int NOT NULL,

	foreign key (IdImagen) references Imagenes(IdImagen),
	foreign key (IdAbono) references Abono(IdAbono)
);

GO

insert into TipoDocumento(NomTipoDcumento)
values ('C.C'),
	   ('C.E'),
	   ('PPT'),
	   ('PA')

insert into Roles(NomRol,Estado)
values ('Administrador',1),
       ('recepcionista',1)

insert into TipoHabitaciones(NomTipoHabitacion,NumeroPersonas,Estado)
values ('Simple',2,1),
       ('Doble',4,1)

insert into Habitaciones(IdTipoHabitacion,Nombre,Estado,Descripcion,Precio)
values (1,'Habitacion Simple',1,'Habitacion para dos personas',200000),
       (2,'Habitacion Doble',1,'Habitacion para cuatro personas',300000)

insert into Muebles(Nombre)
values ('Televisor'),
       ('Aire Acondicionado'),
	   ('Jacuzzi'),
	   ('Fogata'),
	   ('Cama Doble'),
	   ('Cama Sencilla'),
	   ('Espejo de Pie'),
	   ('Hamaca'),
	   ('Lampara de Pie'),
	   ('Estanteria Flotante'),
	   ('2 Camarotes'),
	   ('2 Ba�os'),
	   ('Mesa de Noche'),
	   ('Sofa Cama Pegable'),
	   ('Cajonera')

insert into TipoServicios(NombreTipoServicio)
values ('Comida'),
	   ('Aire libre')

insert into Servicios(IdTipoServicio,NomServicio,Precio,Descripcion,Estado)
values (1,'Desayuno',30000,'Delicioso desayuno',1),
	   (1,'Almuerzo',30000,'Delicioso almuerzo',1),
	   (1,'Cena',30000,'Deliciosa cena',1),
	   (2,'Cabalgata',100000,'Disfruta de una cabalgata',1)


insert into MetodoPago(NomMetodoPago)
values ('Efectivo'),
       ('Targeta'),
	   ('DataCuerpo')

insert into EstadosReserva(NombreEstadoReserva)
values ('Reservado'),
       ('Por Confirmar'),
	   ('Confirmado'),
	   ('En Ejecuci�n'),
	   ('Anulado'),
	   ('Finalizado')

insert into Permisos(NomPermiso)
values ('Dashboard'),
	   ('Listar Roles'),
	   ('Buscar Roles'),
	   ('Crear Roles'),
	   ('Ver Detalles Roles'),
	   ('Editar Roles'),
	   ('Cambiar Estado Roles'),
	   ('Listar Usuarios'),
	   ('Buscar Usuarios'),
	   ('Crear Usuarios'),
	   ('Ver Detalles Usuarios'),
	   ('Editar Usuarios'),
	   ('Cambiar Estado Usuarios'),
	   ('Listar Clientes'),
	   ('Buscar Clientes'),
	   ('Crear Clientes'),
	   ('Ver Detalles Clientes'),
	   ('Editar Clientes'),
	   ('Cambiar Estado Clientes'),
	   ('Listar Habitaciones'),
	   ('Buscar Habitaciones'),
	   ('Crear Habitaciones'),
	   ('Ver Detalles Habitaciones'),
	   ('Editar Habitaciones'),
	   ('Cambiar Estado Habitaciones'),
	   ('Listar Tipo Habitaciones'),
	   ('Buscar Tipo Habitaciones'),
	   ('Crear Tipo Habitaciones'),
	   ('Editar Tipo Habitaciones'),
	   ('Cambiar Estado Tipo Habitaciones'),
	   ('Listar Servicios'),
	   ('Buscar Servicios'),
	   ('Crear Servicios'),
	   ('Ver Detalles Servicios'),
	   ('Editar Servicios'),
	   ('Cambiar Estado Servicios'),
	   ('Listar Tipo Servicio'),
	   ('Buscar Tipo Servicios'),
	   ('Crear Tipo Servicios'),
	   ('Editar Tipo Servicios'),
	   ('Listar Paquetes'),
	   ('Buscar Paquetes'),
	   ('Crear Paquetes'),
	   ('Ver Detalles Paquetes'),
	   ('Editar Paquetes'),
	   ('Cambiar Estado Paquetes'),
	   ('Listar Reservas'),
	   ('Buscar Reservas'),
	   ('Crear Reservas'),
	   ('Ver Detalles Reservas'),
	   ('Editar Reservas'),
	   ('Cambiar Estado Reservas'),
	   ('Anular Reserva'),
	   ('Listar Abono'),
	   ('Buscar Abono'),
	   ('Crear Abono'),
	   ('Ver Detalle Abono'),
	   ('Anular Abono')


insert into PermisosRoles(IdRol,IdPermiso)
values	(1,1),
		(1,2),
		(1,3),
		(1,4),
		(1,5),
		(1,6),
		(1,7),
		(1,8),
		(1,9),
		(1,10),
		(1,11),
		(1,12),
		(1,13),
		(1,14),
		(1,15),
		(1,16),
		(1,17),
		(1,18),
		(1,19),
		(1,20),
		(1,21),
		(1,22),
		(1,23),
		(1,24),
		(1,25),
		(1,26),
		(1,27),
		(1,28),
		(1,29),
		(1,30),
		(1,31),
		(1,32),
		(1,33),
		(1,34),
		(1,35),
		(1,36),
		(1,37),
		(1,38),
		(1,39),
		(1,40),
		(1,41),
		(1,42),
		(1,43),
		(1,44),
		(1,45),
		(1,46),
		(1,47),
		(1,48),
		(1,49),
		(1,50),
		(1,51),
		(1,52),
		(1,53),
		(1,54),
		(1,55),
		(1,56),
		(1,57),
		(1,58)	

