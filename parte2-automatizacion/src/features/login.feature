# language: es
@login
Característica: Inicio de sesión en Casino Atlantic City
  Como jugador registrado
  Quiero iniciar sesión desde el header de la web
  Para acceder a mi cuenta y poder depositar

  Antecedentes:
    Dado que el usuario abre la página del casino
    Cuando hace clic en "Iniciar sesión" de la cabecera

  @smoke @critical @regression
  Escenario: Inicio de sesión exitoso con credenciales válidas
    Y ingresa su nombre de usuario y contraseña
    Y hace clic en el botón "Iniciar sesión" del formulario
    Entonces la sesión se inicia correctamente

  @regression
  Escenario: El botón "Iniciar sesión" está deshabilitado con los campos vacíos
    Entonces el botón "Iniciar sesión" del formulario está deshabilitado
