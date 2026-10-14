/* =============================================================================
   Pregunta 9 - Caso de prueba: Verificar depósitos relacionados con Usuarios (INNER JOIN)
   Criterios:
     - Usuario Testcalimaco35
     - Ordenar mostrando primero el último registro generado
     - Montos de 100
     - Estado del depósito "Pendiente"
     - Moneda Soles (PEN)
   ============================================================================= */

SELECT
    u.IdUsuario,
    u.NombreUsuario,
    u.Email,
    d.IdDeposito,
    d.Monto,
    d.Moneda,
    d.Estado,
    d.FechaCreacion
FROM dbo.Depositos AS d
INNER JOIN dbo.Usuarios AS u
        ON u.IdUsuario = d.UsuarioId    -- relación: Depositos.UsuarioId -> Usuarios.IdUsuario
WHERE u.NombreUsuario = 'Testcalimaco35'
  AND d.Monto  = 100.00
  AND d.Estado = 'Pendiente'
  AND d.Moneda = 'PEN'
ORDER BY
    d.FechaCreacion DESC,               -- primero el último registro generado
    d.IdDeposito    DESC;               -- desempate por IDENTITY

/* Decisiones (criterio QA):
   - INNER JOIN: solo devuelve depósitos que tienen un usuario existente (si hubiera un
     depósito huérfano, no saldría; para detectarlos se usaría LEFT JOIN ... WHERE u.IdUsuario IS NULL).
   - Se filtra por NombreUsuario (UNIQUE en el esquema), no por un IdUsuario fijo, para que la
     consulta funcione en cualquier ambiente (DEV/QA/UAT) donde el Id puede ser distinto.
   - Monto = 100.00 porque la columna es DECIMAL(10,2): 100 y 100.00 son el mismo valor.
   - Resultado esperado con 00_esquema_y_datos_de_prueba.sql: 2 filas (09/10 y luego 08/10).
     No deben aparecer: OtroJugador, USD ni el monto 300.
*/
