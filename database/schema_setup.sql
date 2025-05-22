-- -----------------------------------------------------
-- Script Completo de Creación de Esquema y Datos Iniciales para TPV_Bar (MySQL)
-- -----------------------------------------------------

-- Parte 1: DDL (Data Definition Language) - Creación de Tablas
-- -----------------------------------------------------

SET FOREIGN_KEY_CHECKS=0; -- Deshabilitar temporalmente la revisión de claves foráneas para evitar problemas de orden

-- Table `empresas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `empresas`;
CREATE TABLE IF NOT EXISTS `empresas` (
  `id` INT NOT NULL,
  `Nombre` VARCHAR(45) NULL,
  `Direccion` VARCHAR(45) NULL,
  `Cif` VARCHAR(45) NULL,
  `Telefono` INT NULL,
  `Mail` VARCHAR(45) NULL,
  `Fax` INT NULL,
  `ContadorCod` INT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `camarero`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `camarero`;
CREATE TABLE IF NOT EXISTS `camarero` (
  `IdCamarero` INT NOT NULL AUTO_INCREMENT,
  `IdEmpresa` INT NOT NULL,
  `Nombre` VARCHAR(45) NULL,
  `Apellidos` VARCHAR(100) NULL,
  `Telefono` INT NULL,
  `Activo` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`IdCamarero`),
  INDEX `fk_camarero_empresas_idx` (`IdEmpresa` ASC),
  CONSTRAINT `fk_camarero_empresas`
    FOREIGN KEY (`IdEmpresa`)
    REFERENCES `empresas` (`id`)
    ON DELETE CASCADE -- Si se borra la empresa, se borran sus camareros. O podría ser RESTRICT.
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `categoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `categoria`;
CREATE TABLE IF NOT EXISTS `categoria` (
  `IdCategoria` INT NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(45) NULL,
  `Activo` BOOLEAN NOT NULL DEFAULT TRUE,
  `Color` INT NULL,
  PRIMARY KEY (`IdCategoria`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `productos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `productos`;
CREATE TABLE IF NOT EXISTS `productos` (
  `IdProductos` INT NOT NULL AUTO_INCREMENT,
  `IdCategoria` INT NOT NULL,
  `Nombre` VARCHAR(45) NULL,
  `Precio` DOUBLE NULL,
  `textoBT` VARCHAR(45) NOT NULL,
  `Activo` BOOLEAN NOT NULL DEFAULT TRUE,
  `Color` INT NULL,
  PRIMARY KEY (`IdProductos`),
  INDEX `fk_productos_categoria_idx` (`IdCategoria` ASC),
  CONSTRAINT `fk_productos_categoria`
    FOREIGN KEY (`IdCategoria`)
    REFERENCES `categoria` (`IdCategoria`)
    ON DELETE RESTRICT 
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `bloqueubicacion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bloqueubicacion`;
CREATE TABLE IF NOT EXISTS `bloqueubicacion` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(45) NOT NULL,
  `Descripcion` VARCHAR(100) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ubicacion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ubicacion`;
CREATE TABLE IF NOT EXISTS `ubicacion` (
  `IdUbicacion` INT NOT NULL AUTO_INCREMENT,
  `IdBloqueUbicacion` INT NOT NULL,
  `Nombre` VARCHAR(45) NULL,
  `Descripcion` VARCHAR(100) NULL,
  `Activo` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`IdUbicacion`),
  INDEX `fk_ubicacion_bloqueubicacion_idx` (`IdBloqueUbicacion` ASC),
  CONSTRAINT `fk_ubicacion_bloqueubicacion`
    FOREIGN KEY (`IdBloqueUbicacion`)
    REFERENCES `bloqueubicacion` (`id`)
    ON DELETE CASCADE -- Si se borra un bloque, se borran sus ubicaciones
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `cabezera`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cabezera`;
CREATE TABLE IF NOT EXISTS `cabezera` (
  `IdCabezera` INT NOT NULL AUTO_INCREMENT,
  `IdCamarero` INT NOT NULL,
  `Total` DOUBLE NULL,
  `Estado` INT NULL,
  `Fecha` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `cod` INT NOT NULL,
  PRIMARY KEY (`IdCabezera`),
  INDEX `fk_cabezera_camarero_idx` (`IdCamarero` ASC),
  CONSTRAINT `fk_cabezera_camarero`
    FOREIGN KEY (`IdCamarero`)
    REFERENCES `camarero` (`IdCamarero`)
    ON DELETE RESTRICT
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `caja`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caja`;
CREATE TABLE IF NOT EXISTS `caja` (
  `idCaja` INT NOT NULL AUTO_INCREMENT,
  `IdCamarero` INT NOT NULL,
  `IdCabezera` INT NULL,
  `fecha` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `movimiento` DOUBLE NOT NULL,
  `saldo` DOUBLE NOT NULL,
  `descripcion` VARCHAR(255) NULL,
  `cajaPago` INT NOT NULL, -- 0: Efectivo, 1: Tarjeta, 2: Otro (ejemplo)
  PRIMARY KEY (`idCaja`),
  INDEX `fk_caja_camarero_idx` (`IdCamarero` ASC),
  INDEX `fk_caja_cabezera_idx` (`IdCabezera` ASC),
  CONSTRAINT `fk_caja_camarero0` -- Renombrada para evitar conflicto si se ejecuta multiples veces
    FOREIGN KEY (`IdCamarero`)
    REFERENCES `camarero` (`IdCamarero`)
    ON DELETE RESTRICT 
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_caja_cabezera0` -- Renombrada
    FOREIGN KEY (`IdCabezera`)
    REFERENCES `cabezera` (`IdCabezera`)
    ON DELETE SET NULL 
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `arqueos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `arqueos`;
CREATE TABLE IF NOT EXISTS `arqueos` (
  `idArqueo` INT NOT NULL AUTO_INCREMENT,
  `IdCaja` INT NOT NULL,
  `Fecha` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Diferencia` DOUBLE NOT NULL,
  PRIMARY KEY (`idArqueo`),
  INDEX `fk_arqueos_caja_idx` (`IdCaja` ASC),
  CONSTRAINT `fk_arqueos_caja`
    FOREIGN KEY (`IdCaja`)
    REFERENCES `caja` (`idCaja`)
    ON DELETE CASCADE 
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `linea`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `linea`;
CREATE TABLE IF NOT EXISTS `linea` (
  `IdLinea` INT NOT NULL AUTO_INCREMENT,
  `IdProductos` INT NOT NULL,
  `IdCabezera` INT NULL, 
  `IdUbicacion` INT NOT NULL,
  `Precio` DOUBLE NULL,
  `catidad` DOUBLE NULL, 
  `Total` DOUBLE NULL,
  `cobrado` INT NOT NULL DEFAULT 0, -- 0: Pendiente, 1: Cobrado (ejemplo)
  `Invitacion` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`IdLinea`),
  INDEX `fk_linea_productos_idx` (`IdProductos` ASC),
  INDEX `fk_linea_cabezera_idx` (`IdCabezera` ASC),
  INDEX `fk_linea_ubicacion_idx` (`IdUbicacion` ASC),
  CONSTRAINT `fk_linea_productos`
    FOREIGN KEY (`IdProductos`)
    REFERENCES `productos` (`IdProductos`)
    ON DELETE RESTRICT 
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_linea_cabezera`
    FOREIGN KEY (`IdCabezera`)
    REFERENCES `cabezera` (`IdCabezera`)
    ON DELETE CASCADE 
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_linea_ubicacion`
    FOREIGN KEY (`IdUbicacion`)
    REFERENCES `ubicacion` (`IdUbicacion`)
    ON DELETE RESTRICT 
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `atipicas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `atipicas`;
CREATE TABLE IF NOT EXISTS `atipicas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `productos` INT NOT NULL, 
  `bloqueubicacion` INT NOT NULL, 
  `tipo` INT NOT NULL, -- Ej: 0: Precio especial, 1: No disponible
  `precio` DOUBLE NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_atipicas_productos_idx` (`productos` ASC),
  INDEX `fk_atipicas_bloqueubicacion_idx` (`bloqueubicacion` ASC),
  CONSTRAINT `fk_atipicas_productos`
    FOREIGN KEY (`productos`)
    REFERENCES `productos` (`IdProductos`)
    ON DELETE CASCADE 
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_atipicas_bloqueubicacion`
    FOREIGN KEY (`bloqueubicacion`)
    REFERENCES `bloqueubicacion` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `configuracion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `configuracion`;
CREATE TABLE IF NOT EXISTS `configuracion` (
  `id` INT NOT NULL,
  `clave` VARCHAR(45) NOT NULL,
  `value` VARCHAR(255) NULL, -- Aumentado tamaño para valores más largos
  PRIMARY KEY (`id`),
  UNIQUE INDEX `clave_UNIQUE` (`clave` ASC)) -- Clave debe ser única
ENGINE = InnoDB;

SET FOREIGN_KEY_CHECKS=1; -- Reactivar la revisión de claves foráneas

-- -----------------------------------------------------
-- Parte 2: DML (Data Manipulation Language) - Inserción de Datos Iniciales
-- -----------------------------------------------------

-- Empresa por defecto
INSERT INTO `empresas` (`id`, `Nombre`, `Direccion`, `Cif`, `Telefono`, `Mail`, `ContadorCod`) VALUES
(1, 'Mi Bar TPV', 'Calle Principal 123, Ciudad', 'A12345678', 912345678, 'info@mibartpv.com', 1)
ON DUPLICATE KEY UPDATE Nombre=VALUES(Nombre), Direccion=VALUES(Direccion), Cif=VALUES(Cif), Telefono=VALUES(Telefono), Mail=VALUES(Mail), ContadorCod=VALUES(ContadorCod);

-- Camarero por defecto (asume IdEmpresa=1)
INSERT INTO `camarero` (`IdCamarero`, `IdEmpresa`, `Nombre`, `Apellidos`, `Activo`) VALUES
(1, 1, 'Admin', 'User', TRUE)
ON DUPLICATE KEY UPDATE IdEmpresa=VALUES(IdEmpresa), Nombre=VALUES(Nombre), Apellidos=VALUES(Apellidos), Activo=VALUES(Activo);

-- Bloques de Ubicación
INSERT INTO `bloqueubicacion` (`id`, `Nombre`, `Descripcion`) VALUES
(1, 'Barra', 'Zona de la barra principal'),
(2, 'Salón Principal', 'Mesas del salón interior'),
(3, 'Terraza Exterior', 'Mesas en el exterior')
ON DUPLICATE KEY UPDATE Nombre=VALUES(Nombre), Descripcion=VALUES(Descripcion);

-- Ubicaciones (Mesas/Sitios)
-- Se limpian datos de ubicaciones antes de insertar para evitar duplicados si se ejecuta varias veces
-- DELETE FROM ubicacion WHERE IdBloqueUbicacion IN (1,2,3); -- Comentado por si se prefiere control manual
INSERT INTO `ubicacion` (`IdBloqueUbicacion`, `Nombre`, `Activo`) VALUES
(1, 'B1', TRUE), (1, 'B2', TRUE), (1, 'B3', TRUE),
(2, 'M01', TRUE), (2, 'M02', TRUE), (2, 'M03', TRUE), (2, 'M04', TRUE), (2, 'M05', TRUE),
(3, 'T01', TRUE), (3, 'T02', TRUE), (3, 'T03', TRUE), (3, 'T04', TRUE);


-- Categorías de Productos
INSERT INTO `categoria` (`idCategoria`, `Nombre`, `Activo`, `Color`) VALUES
(1, 'Refrescos', TRUE, -16776961),      -- Azul
(2, 'Cervezas', TRUE, -256),           -- Amarillo
(3, 'Vinos', TRUE, -7667712),          -- Púrpura
(4, 'Combinados', TRUE, -16711681),    -- Cyan
(5, 'Tapas Frías', TRUE, -65536),      -- Rojo
(6, 'Tapas Calientes', TRUE, -23296),  -- Naranja
(7, 'Raciones', TRUE, -16711936),      -- Verde
(8, 'Bocadillos', TRUE, -4144960),     -- Marrón claro
(9, 'Cafés & Infusiones', TRUE, -10066330) -- Marrón oscuro
ON DUPLICATE KEY UPDATE Nombre=VALUES(Nombre), Activo=VALUES(Activo), Color=VALUES(Color);

-- Productos de Ejemplo
-- (Asumiendo IDs de categoría insertados previamente)
-- Se limpian datos de productos antes de insertar para evitar duplicados si se ejecuta varias veces
-- DELETE FROM productos WHERE IdCategoria IN (1,2,3,4,5,6,7,8,9); -- Comentado
INSERT INTO `productos` (`IdCategoria`, `Nombre`, `Precio`, `textoBT`, `Activo`) VALUES
(1, 'Cola Normal', 2.20, 'COLA N', TRUE),
(1, 'Cola Zero', 2.20, 'COLA Z', TRUE),
(1, 'Naranjada', 2.20, 'NARAN', TRUE),
(1, 'Limonada', 2.20, 'LIMON', TRUE),
(1, 'Agua 50cl', 1.80, 'AGUA P', TRUE),
(2, 'Caña Cerveza', 1.90, 'CAÑA', TRUE),
(2, 'Doble Cerveza', 2.80, 'DOBLE', TRUE),
(2, 'Tercio Mahou', 3.20, 'TERCIO M', TRUE),
(2, 'Alhambra 1925', 3.50, 'ALH1925', TRUE),
(3, 'Copa Rioja', 2.50, 'RIOJA', TRUE),
(3, 'Copa Ribera', 2.70, 'RIBERA', TRUE),
(3, 'Copa Rueda', 2.50, 'RUEDA', TRUE),
(5, 'Ensaladilla Rusa', 4.00, 'ENS.RUS', TRUE),
(5, 'Patatas Alioli', 3.50, 'ALIOLI', TRUE),
(6, 'Croquetas Caseras (6ud)', 7.00, 'CROQ CS', TRUE),
(6, 'Calamares Romana', 9.00, 'CALAMAR', TRUE),
(6, 'Bravas TPV', 5.00, 'BRAVAS', TRUE),
(9, 'Café Solo', 1.40, 'SOLO', TRUE),
(9, 'Café con Leche', 1.60, 'C/LECHE', TRUE),
(9, 'Infusión Manzanilla', 1.50, 'MANZAN', TRUE);


-- Configuración Inicial
INSERT INTO `configuracion` (`id`, `clave`, `value`) VALUES
(1, 'EMPRESA_ID_ACTUAL', '1'), 
(2, 'MOSTRAR_TOTAL_IVAINCLUIDO', 'TRUE'), 
(3, 'PORCENTAJE_IVA_GENERAL', '10'), 
(4, 'PORCENTAJE_IVA_REDUCIDO', '10'),
(5, 'IMPRESORA_TICKETS', 'EPSON TM-T20II'), 
(6, 'IMPRESORA_COCINA', 'NINGUNA'), 
(7, 'MENSAJE_PIE_TICKET_L1', 'Gracias por su visita'),
(8, 'MENSAJE_PIE_TICKET_L2', '¡Vuelva pronto!'),
(9, 'PEDIR_CIF_FACTURA_SIMPLIFICADA', 'FALSE'),
(10, 'MAX_DESCUENTO_PERMITIDO_PORC', '20')
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`);

-- Apertura de caja inicial para el camarero Admin (IdCamarero=1)
-- INSERT INTO `caja` (`IdCamarero`, `fecha`, `movimiento`, `saldo`, `descripcion`, `cajaPago`) 
-- VALUES (1, NOW(), 0, 0, 'APERTURA INICIAL SISTEMA', 0)
-- ON DUPLICATE KEY UPDATE saldo=VALUES(saldo); 

-- -----------------------------------------------------
-- Fin del Script
-- -----------------------------------------------------
```
