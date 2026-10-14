/* =============================================================================
   Pregunta 8 - Caso de prueba: Verificar depósitos consultando la tabla Depositos
   Criterios:
     - Ordenar mostrando primero el último registro generado
     - Montos entre 10 y 100
     - Estado del depósito "Exitoso"
     - Moneda Soles (PEN)
   ============================================================================= */

SELECT
    d.IdDeposito,
    d.UsuarioId,
    d.Monto,
    d.Moneda,
    d.Estado,
    d.FechaCreacion
FROM dbo.Depositos AS d
WHERE d.Monto BETWEEN 10 AND 100        -- BETWEEN incluye ambos límites: 10.00 y 100.00
  AND d.Estado = 'Exitoso'
  AND d.Moneda = 'PEN'
ORDER BY
    d.FechaCreacion DESC,               -- primero el último registro generado
    d.IdDeposito    DESC;               -- desempate: si dos depósitos tienen la misma fecha,
                                        -- el IDENTITY mayor es el último insertado

/* Decisiones (criterio QA):
   - Columnas explícitas en vez de SELECT *: la consulta no cambia si se agregan columnas.
   - BETWEEN 10 AND 100 es equivalente a  Monto >= 10 AND Monto <= 100 (límites incluidos).
   - Resultado esperado con 00_esquema_y_datos_de_prueba.sql: 3 filas
     (100.00 del 03/10, 55.50 del 02/10, 10.00 del 01/10). No deben aparecer 9.99, 100.01,
     USD ni Fallido.
*/
