# P5 - Técnicas de caja negra

Estas técnicas sirven para diseñar los casos a partir de los requisitos, sin mirar el código. Para "Pago con QR" usaría las siguientes.

## 1. Partición de equivalencia

Divido los valores en grupos que el sistema debería tratar igual y pruebo uno de cada grupo.

Ejemplo con el campo "Otro monto" (mínimo S/10, máximo S/500):

| Grupo | Ejemplo | Resultado esperado |
|---|---|---|
| Menor a 10 | 5 | Mensaje de mínimo, SIGUIENTE deshabilitado |
| Entre 10 y 500 | 250 | Genera el QR |
| Mayor a 500 | 800 | Mensaje de máximo, SIGUIENTE deshabilitado |
| No numérico | abc | No lo acepta |
| Vacío | (vacío) | SIGUIENTE deshabilitado |
| Cero o negativo | -10 | No lo acepta |

## 2. Valores límite

Los errores suelen estar en los bordes, por ejemplo cuando el desarrollador usó `<` en lugar de `<=`. Como el monto tiene 2 decimales, pruebo justo en cada límite y un céntimo antes y después:

| Valor | Esperado |
|---|---|
| 9.99 | No permite |
| 10.00 | Permite |
| 10.01 | Permite |
| 499.99 | Permite |
| 500.00 | Permite |
| 500.01 | No permite |

Estos valores están en los escenarios de valores límite del feature de la P1. También los usé en los datos de prueba de la P8 (9.99 y 100.01).

## 3. Tabla de decisión

La uso cuando el resultado depende de varias condiciones a la vez. Ejemplo: ¿se acredita el depósito?

| Condición | R1 | R2 | R3 | R4 | R5 |
|---|---|---|---|---|---|
| Sesión activa | Sí | No | Sí | Sí | Sí |
| Monto válido | Sí | - | No | Sí | Sí |
| QR vigente | Sí | - | - | No | Sí |
| QR no usado | Sí | - | - | - | No |
| Resultado | Acredita | Va al login | No genera el QR | Rechaza por expirado | Rechaza por QR ya usado |

Cada columna es un caso de prueba.

## 4. Transición de estados

El depósito pasa por estados, así que pruebo los cambios válidos y verifico que los inválidos no ocurran:

- Pendiente → Exitoso, cuando la pasarela confirma el pago (se acredita una sola vez).
- Pendiente → Fallido, cuando la billetera rechaza el pago.
- Pendiente → Fallido/Expirado, cuando vence el QR.
- Exitoso + una segunda confirmación → debe seguir en Exitoso, sin acreditar dos veces.
- Fallido + una confirmación tardía → no debe pasar a Exitoso sin conciliación.

## 5. Casos de uso

Recorro el flujo completo como lo hace el usuario: login, DEPOSITAR, Pago con QR, monto, SIGUIENTE, pago y saldo actualizado. Además pruebo sus variantes: volver atrás, cerrar o cambiar de monto.

## 6. Error guessing

Por experiencia, en pasarelas de pago suelo probar:

- Doble clic en SIGUIENTE.
- Recargar la página con el QR abierto.
- Pagar desde dos pestañas a la vez.
- Escribir el monto con coma (10,50) o con espacios.
- Pegar "S/ 100" en el campo.
- Cambiar el monto en el request.
