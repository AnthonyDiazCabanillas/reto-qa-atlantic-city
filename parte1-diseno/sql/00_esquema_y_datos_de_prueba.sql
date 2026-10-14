/* =============================================================================
   Esquema (Anexo 2) + datos de prueba para ejecutar y validar las consultas P8 y P9.
   Motor: SQL Server. Ejecutar en una BD de pruebas (NO en producción).
   Los datos están diseñados con valores límite para comprobar cada filtro:
   montos 9.99 / 10 / 100 / 100.01, otros estados, otra moneda y otro usuario.
   ============================================================================= */

IF OBJECT_ID('dbo.Depositos', 'U') IS NOT NULL DROP TABLE dbo.Depositos;
IF OBJECT_ID('dbo.Usuarios',  'U') IS NOT NULL DROP TABLE dbo.Usuarios;
GO

CREATE TABLE dbo.Usuarios (
    IdUsuario     INT IDENTITY(1,1) PRIMARY KEY,
    NombreUsuario VARCHAR(50)  NOT NULL UNIQUE,
    Email         VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Depositos (
    IdDeposito    INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioId     INT           NOT NULL,
    Monto         DECIMAL(10,2) NOT NULL,
    Moneda        CHAR(3)       NOT NULL,
    Estado        VARCHAR(20)   NOT NULL,
    FechaCreacion DATETIME      NOT NULL DEFAULT GETDATE()
);
-- Fechas en formato ISO 8601 (AAAA-MM-DDThh:mm:ss): en SQL Server es un formato de DATETIME
-- que no depende del idioma/DATEFORMAT de la sesión (con idioma español, '2026-10-13 10:00:00' falla
-- porque lo lee como año-día-mes).
-- Nota QA: el Anexo 2 no define FOREIGN KEY entre Depositos.UsuarioId y Usuarios.IdUsuario.
-- Es una observación a reportar: sin FK pueden existir depósitos "huérfanos".
GO

INSERT INTO dbo.Usuarios (NombreUsuario, Email) VALUES
('Testcalimaco35', 'testcalimaco35@correo.com'),   -- IdUsuario = 1
('OtroJugador',    'otro.jugador@correo.com');     -- IdUsuario = 2

INSERT INTO dbo.Depositos (UsuarioId, Monto, Moneda, Estado, FechaCreacion) VALUES
-- Esperados en P8 (10..100, Exitoso, PEN)
(1,  10.00, 'PEN', 'Exitoso',   '2026-10-01T09:00:00'),  -- límite inferior
(2,  55.50, 'PEN', 'Exitoso',   '2026-10-02T10:00:00'),
(1, 100.00, 'PEN', 'Exitoso',   '2026-10-03T11:00:00'),  -- límite superior
-- NO deben salir en P8
(1,   9.99, 'PEN', 'Exitoso',   '2026-10-04T12:00:00'),  -- debajo del mínimo
(1, 100.01, 'PEN', 'Exitoso',   '2026-10-05T13:00:00'),  -- encima del máximo
(1,  50.00, 'USD', 'Exitoso',   '2026-10-06T14:00:00'),  -- otra moneda
(1,  50.00, 'PEN', 'Fallido',   '2026-10-07T15:00:00'),  -- otro estado
-- Esperados en P9 (Testcalimaco35, 100, Pendiente, PEN)
(1, 100.00, 'PEN', 'Pendiente', '2026-10-08T16:00:00'),
(1, 100.00, 'PEN', 'Pendiente', '2026-10-09T17:00:00'),
-- NO deben salir en P9
(2, 100.00, 'PEN', 'Pendiente', '2026-10-10T18:00:00'),  -- otro usuario
(1, 100.00, 'USD', 'Pendiente', '2026-10-11T19:00:00'),  -- otra moneda
(1, 300.00, 'PEN', 'Pendiente', '2026-10-12T20:00:00');  -- otro monto
GO
