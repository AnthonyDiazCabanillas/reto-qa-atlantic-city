# language: es
#
# Reto Técnico - Analista QA Senior - Casino Atlantic City
# Pregunta 1: Casos de prueba en Gherkin para el Depósito con la pasarela "Pago con QR"
# Pregunta 2: Etiquetado @critical / @smoke / @regression
#
# Reglas de negocio tomadas del Anexo 1 (pantalla "Pago con QR"):
#   R1. Solo un usuario autenticado puede depositar (botón "DEPOSITAR" del header).
#   R2. Montos rápidos: S/10, S/100 y S/300. Opción "Otro monto" para ingresar uno libre.
#   R3. Monto mínimo por transacción: S/10. Monto máximo por transacción: S/500.
#   R4. El botón "SIGUIENTE" está deshabilitado hasta que haya un monto válido.
#   R5. Se genera un código QR que se paga con billeteras (Plin, Yape y +16 más).
#   R6. Estados del depósito en BD: Pendiente -> Exitoso | Fallido. Moneda: PEN.
#
# Criterio de etiquetas (Pregunta 2):
#   @smoke      -> pocos escenarios, rápidos, que confirman que el flujo principal "vive".
#                  Se ejecutan en cada despliegue.
#   @critical   -> si fallan, hay pérdida de dinero, riesgo de seguridad o el usuario
#                  no puede depositar. Bloquean un pase a producción.
#   @regression -> todo lo que debe volver a probarse ante cualquier cambio.
#                  Todo escenario @smoke y @critical también es @regression.
#
# Etiquetas por tipo de camino: @happy-path @alternative-path @negative-path
#                               @exception-path @security-path @performance-path

@deposito @pago-qr
Característica: Depósito mediante la pasarela "Pago con QR"
  Como jugador registrado del casino online
  Quiero depositar dinero generando un código QR
  Para pagarlo con mi billetera digital y tener saldo para jugar

  Antecedentes:
    Dado que el usuario "Testcalimaco34" inició sesión en https://www.casinoatlanticcity.com/
    Y hace clic en el botón "DEPOSITAR" del header
    Y selecciona la pasarela "PAGO CON QR"

  # ===========================================================================
  # HAPPY PATH - el camino ideal, todo sale bien
  # ===========================================================================

  @happy-path @smoke @critical @regression
  Esquema del escenario: Depósito exitoso con un monto rápido
    Cuando selecciona el monto rápido "<monto>"
    Y hace clic en "SIGUIENTE"
    Entonces se muestra un código QR para pagar S/<valor>
    Cuando paga el QR desde su billetera digital
    Entonces se muestra el mensaje de depósito exitoso
    Y su saldo aumenta en S/<valor>
    Y en la tabla Depositos queda un registro con Monto <valor>, Moneda "PEN" y Estado "Exitoso"

    Ejemplos:
      | monto | valor  |
      | S/10  | 10.00  |
      | S/100 | 100.00 |
      | S/300 | 300.00 |

  @happy-path @smoke @regression
  Escenario: La pantalla de la pasarela muestra la información correcta
    Entonces se muestra el título "Pago con QR"
    Y se muestran los logos de las billeteras "Plin", "Yape" y "+16"
    Y se muestran los montos rápidos "S/10", "S/100", "S/300" y la opción "Otro monto"
    Y se muestra el texto "Monto mínimo por transacción: S/10."
    Y se muestra el texto "El monto máximo por transacción es de S/500."
    Y el botón "SIGUIENTE" está deshabilitado

  # ===========================================================================
  # ALTERNATIVE PATH - otro camino válido para llegar al mismo objetivo
  # ===========================================================================

  @alternative-path @critical @regression
  Esquema del escenario: Depósito exitoso ingresando "Otro monto" dentro del rango (valores límite válidos)
    Cuando selecciona "Otro monto"
    Y ingresa el monto "<monto>"
    Entonces el botón "SIGUIENTE" se habilita
    Cuando hace clic en "SIGUIENTE"
    Entonces se muestra un código QR para pagar S/<monto>
    Cuando paga el QR desde su billetera digital
    Entonces el depósito queda en estado "Exitoso"

    Ejemplos: Valores límite y partición válida
      | monto  | tecnica                         |
      | 10     | límite inferior exacto          |
      | 10.01  | justo encima del mínimo         |
      | 250    | valor representativo del rango  |
      | 499.99 | justo debajo del máximo         |
      | 500    | límite superior exacto          |

  @alternative-path @regression
  Esquema del escenario: Pagar el QR con distintas billeteras digitales
    Cuando selecciona el monto rápido "S/100"
    Y hace clic en "SIGUIENTE"
    Y paga el QR usando la billetera "<billetera>"
    Entonces el depósito queda en estado "Exitoso"

    Ejemplos:
      | billetera        |
      | Yape             |
      | Plin             |
      | Banca móvil BCP  |
      | Banca móvil BBVA |

  @alternative-path @regression
  Escenario: Cambiar de monto antes de generar el QR
    Cuando selecciona el monto rápido "S/10"
    Y luego selecciona el monto rápido "S/300"
    Entonces solo el monto "S/300" queda seleccionado
    Cuando hace clic en "SIGUIENTE"
    Entonces se muestra un código QR para pagar S/300.00

  @alternative-path @regression
  Escenario: Volver atrás desde la pasarela con la flecha
    Cuando hace clic en la flecha "←" de la cabecera de "Pago con QR"
    Entonces vuelve a la lista de métodos de depósito
    Y no se crea ningún registro en la tabla Depositos

  @alternative-path @regression
  Escenario: Cerrar la pasarela con la "X" sin generar QR
    Cuando hace clic en la "X" de la ventana
    Entonces se cierra el modal de depósito
    Y el saldo del usuario no cambia

  @alternative-path @regression
  Escenario: Consultar la ayuda "¿Cómo depositar?"
    Cuando hace clic en "¿Cómo depositar?"
    Entonces se despliegan las instrucciones para pagar con QR

  # ===========================================================================
  # NEGATIVE PATH - datos inválidos: el sistema debe rechazarlos con un mensaje claro
  # ===========================================================================

  @negative-path @critical @regression
  Esquema del escenario: No permite montos fuera del rango permitido (valores límite inválidos)
    Cuando selecciona "Otro monto"
    Y ingresa el monto "<monto>"
    Entonces se muestra el mensaje "<mensaje>"
    Y el botón "SIGUIENTE" permanece deshabilitado
    Y no se genera ningún código QR

    Ejemplos: Valores límite y particiones inválidas
      | monto  | mensaje                                       |
      | 9.99   | Monto mínimo por transacción: S/10.           |
      | 0      | Monto mínimo por transacción: S/10.           |
      | -10    | Monto mínimo por transacción: S/10.           |
      | 500.01 | El monto máximo por transacción es de S/500.  |
      | 1000   | El monto máximo por transacción es de S/500.  |

  @negative-path @regression
  Esquema del escenario: No permite valores con formato inválido en "Otro monto"
    Cuando selecciona "Otro monto"
    Y ingresa el valor "<valor>"
    Entonces el campo no acepta el valor o muestra un mensaje de monto inválido
    Y el botón "SIGUIENTE" permanece deshabilitado

    Ejemplos:
      | valor   | caso                         |
      | abc     | letras                       |
      | 10,5,5  | separadores mal formados     |
      | 100.555 | más de 2 decimales           |
      | @#$     | caracteres especiales        |
      | (vacío) | campo vacío                  |
      |    50   | espacios alrededor del valor |

  @negative-path @smoke @regression
  Escenario: El botón "SIGUIENTE" está deshabilitado si no se elige un monto
    Cuando no selecciona ningún monto
    Entonces el botón "SIGUIENTE" está deshabilitado

  @negative-path @regression
  Escenario: Pago rechazado por la billetera (saldo insuficiente)
    Cuando selecciona el monto rápido "S/300"
    Y hace clic en "SIGUIENTE"
    Y intenta pagar el QR con una billetera sin saldo suficiente
    Entonces la billetera rechaza el pago
    Y el depósito queda en estado "Fallido"
    Y el saldo del usuario en el casino no cambia

  @negative-path @critical @regression
  Escenario: Un usuario sin sesión no puede depositar
    Dado que el usuario no ha iniciado sesión
    Cuando intenta acceder directamente a la URL del módulo de depósito
    Entonces es redirigido al login
    Y no se muestra la pasarela "Pago con QR"

  # ===========================================================================
  # EXCEPTION PATH - el usuario hizo todo bien, pero el sistema o un tercero falla
  # ===========================================================================

  @exception-path @critical @regression
  Escenario: Timeout con la pasarela de pago al generar el QR
    Dado que el servicio de la pasarela de pago no responde dentro del tiempo límite
    Cuando selecciona el monto rápido "S/100"
    Y hace clic en "SIGUIENTE"
    Entonces se muestra un mensaje amigable "No pudimos generar tu QR, inténtalo nuevamente"
    Y no se muestra un QR incompleto o inválido
    Y no se descuenta ni se acredita ningún saldo

  @exception-path @critical @regression
  Escenario: El usuario pagó, pero la confirmación de la pasarela llega tarde
    Dado que el usuario pagó el QR de S/100 desde su billetera
    Y la notificación de la pasarela al casino se demora
    Entonces el depósito permanece en estado "Pendiente"
    Cuando la notificación llega
    Entonces el depósito cambia a estado "Exitoso"
    Y el saldo se acredita una sola vez

  @exception-path @critical @regression
  Escenario: La pasarela confirma el mismo pago dos veces (notificación duplicada)
    Dado que el usuario pagó un QR de S/100
    Cuando la pasarela envía dos veces la confirmación del mismo pago
    Entonces el saldo se acredita solo una vez con S/100
    Y existe un solo registro "Exitoso" para esa transacción

  @exception-path @regression
  Escenario: Se pierde la conexión a internet mientras se genera el QR
    Cuando selecciona el monto rápido "S/10"
    Y pierde la conexión a internet al hacer clic en "SIGUIENTE"
    Entonces se muestra un mensaje de "Sin conexión"
    Y al recuperar la conexión puede volver a intentar el depósito

  @exception-path @regression
  Escenario: El servicio de depósitos (backend) devuelve un error 500
    Dado que el servicio de depósitos responde con error 500
    Cuando intenta generar un QR de S/100
    Entonces se muestra un mensaje genérico sin detalles técnicos
    Y el error queda registrado en los logs para soporte

  # ===========================================================================
  # SECURITY PATH - intentos de abuso o fraude
  # ===========================================================================

  @security-path @critical @regression
  Escenario: No permite la reutilización de un QR ya pagado
    Dado que el usuario generó un QR de S/100 y lo pagó con éxito
    Cuando intenta pagar el mismo QR otra vez
    Entonces la billetera o la pasarela rechazan el pago por "QR ya utilizado"
    Y el saldo se acreditó una sola vez

  @security-path @critical @regression
  Escenario: Un QR expirado no se puede pagar
    Dado que el usuario generó un QR de S/100
    Y pasó el tiempo de vigencia del QR
    Cuando intenta pagarlo
    Entonces el pago es rechazado por "QR expirado"
    Y el depósito queda en estado "Fallido"

  @security-path @critical @regression
  Escenario: No se puede alterar el monto en la petición al servidor
    Cuando selecciona el monto rápido "S/10"
    Y modifica el monto a 5000 en la petición HTTP antes de enviarla
    Entonces el servidor rechaza la solicitud por monto fuera de rango
    Y no se genera ningún QR

  @security-path @critical @regression
  Escenario: Un usuario no puede ver ni usar el depósito de otro usuario
    Dado que existe un depósito del usuario A
    Cuando el usuario B cambia el identificador del depósito en la petición
    Entonces el servidor responde "acceso denegado" (403)
    Y no se muestran datos del depósito del usuario A

  @security-path @regression
  Escenario: La sesión expirada no permite generar un QR
    Dado que la sesión del usuario expiró
    Cuando hace clic en "SIGUIENTE" con un monto válido
    Entonces es redirigido al login
    Y no se genera ningún QR

  @security-path @regression
  Escenario: El campo "Otro monto" no ejecuta código malicioso
    Cuando selecciona "Otro monto"
    Y ingresa el valor "<script>alert(1)</script>"
    Entonces el valor es rechazado
    Y no se ejecuta ningún script en la página

  @security-path @regression
  Escenario: La comunicación con la pasarela es segura
    Cuando genera un QR de S/100
    Entonces todas las peticiones viajan por HTTPS
    Y la respuesta no expone datos sensibles (tokens, datos de la billetera)

  # ===========================================================================
  # PERFORMANCE PATH - qué tan rápido y cuánta carga aguanta
  # ===========================================================================

  @performance-path @critical @regression
  Escenario: La generación del QR toma menos de 3 segundos
    Cuando selecciona el monto rápido "S/100"
    Y hace clic en "SIGUIENTE"
    Entonces el código QR se muestra en menos de 3 segundos

  @performance-path @critical @regression
  Escenario: Múltiples depósitos simultáneos de distintos usuarios
    Dado que 500 usuarios autenticados están en la pasarela "Pago con QR"
    Cuando todos generan un QR al mismo tiempo
    Entonces el 95% de los QR se generan en menos de 3 segundos
    Y la tasa de error es menor al 1%
    Y cada depósito queda registrado una sola vez con su monto correcto

  @performance-path @regression
  Escenario: El mismo usuario hace varios clics seguidos en "SIGUIENTE"
    Cuando selecciona el monto rápido "S/100"
    Y hace 5 clics rápidos en "SIGUIENTE"
    Entonces se genera un solo código QR
    Y existe un solo registro "Pendiente" en la tabla Depositos

  @performance-path @regression
  Escenario: La confirmación del pago se refleja rápido en el saldo
    Dado que el usuario pagó un QR de S/100
    Entonces el saldo se actualiza en menos de 10 segundos después de la confirmación
