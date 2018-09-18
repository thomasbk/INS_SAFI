// Conexión con el web service
#define WS_REQUEST_CONTENT_TYPE @"application/json"
//#define WS_REQUEST_URL @"http://10.30.1.51/INSVA.AppMovil/%@.svc/JSON/%@"
//#define WS_REQUEST_URL @"https://www.insvalores.com/INSVA.interfaceappmovil/%@.svc/JSON/%@"
#define WS_REQUEST_URL @"https://www.insinversiones.com/INSSAFI.InterfaceAppMovil/AppMovilServiceInterface.svc/json/%@"


#define WS_SERVICE_USUARIO @"AppMovilServiceInterface"
//#define WS_SERVICE_USUARIO @"AppMovilService"

// SAFI
#define WS_METHOD_TRAER_INFO_CONTACTO "TraerInfoContacto"
#define WS_METHOD_DIST_MONEDA "TraerDistXMoneda"

#define WS_METHOD_SALDOS_ACTUALES "TraerSaldosActuales"
#define WS_METHOD_FONDOS_CUENTA "TraerFondosCuenta"
#define WS_METHOD_RESUMEN_ESTADO_DE_CUENTA "TraerResumenEstadoDeCuenta"
#define WS_METHOD_ESTADO_DE_CUENTA "TraerEstadoDeCuenta"
#define WS_METHOD_INFO_CLIENTE "TraerInfoCliente"
#define WS_METHOD_LISTA_VENCIMIENTOS "TraerListaVencimientos"
#define WS_METHOD_INDICADORES_FONDOS "TraerIndicadoresFondos"
#define WS_METHOD_INDICADORES_ECONOMICOS "TraerIndicadoresEconomicos"
#define WS_METHOD_INFORMACION_ASESOR "TraerInformacionAsesor"
#define WS_METHOD_REMITIR_MENSAJE "RemitirMensajeAsesor"
#define WS_METHOD_FONDOS_PORTAFOLIO "TraerFondosCalcPortafolio"
#define WS_METHOD_TRAER_TIPO_CAMBIO "TraerTipoCambio"
#define WS_METHOD_CALCULAR_PORTAFOLIO "CalcularPortafolio"
#define WS_METHOD_CUENTAS_FAVORITAS "TraerCuentasFavoritas"
#define WS_METHOD_GRABAR_FAVORITA "GrabarCuentaFavorita"
#define WS_METHOD_VERIFICAR_FAVORITA "VerificaInformacionCuentaFav"
#define WS_METHOD_CODIGO_VERIFICACION "VerificarCodigoVerificacion"
#define WS_METHOD_TRAER_CORREOS "TraerCorreosPersona"
<<<<<<< HEAD
#define WS_METHOD_GRABAR_VENCIMIENTO "GrabarInstruccionVencimiento"
#define WS_METHOD_TRAER_BANCARIAS "TraerCuentasBancariasRetiro"
#define WS_METHOD_TRAER_OPERACIONES "TraerListaOperaciones"
#define WS_METHOD_OPERACIONES_IMPRIMIR "TraerOperacionImprimir"

=======
#define WS_METHOD_SOLICITUDES "TraerListaSolicitudes"
#define WS_METHOD_CUENTAS_BANCARIAS_RETIRO "TraerCuentasBancariasRetiro"
#define WS_METHOD_GRABAR_SOLICITUD "GrabarSolicitudes"
>>>>>>> 1f49744c99d4e072e97b9e60161fe5f2e1fb8b12






// LOGIN
#define WS_METHOD_VALIDAR_USUARIO_PASSWORD @"ValidarUsuario"
#define WS_METHOD_VALIDAR_CERRAR_SESION @"CerrarSesion"
// REGISTRO
#define WS_METHOD_TIPOS_IDENTIFICACIONES @"TraerTiposIdentificaciones"
#define WS_METHOD_TRAER_PERSONA_PADRON @"TraerPersonaPadron"
#define WS_METHOD_REGISTRAR_USUARIO @"RegistrarUsuario"
// RECUPERAR CLAVE
#define WS_METHOD_RECUPERAR_CLAVE @"RecuperarPassword"
// CARTERA
#define WS_METHOD_SUBCUENTAS @"TraerSubcuentas"
#define WS_METHOD_TRAER_PATRIMONIO @"TraerPatrimonio"
#define WS_METHOD_TRAER_RESUMEN_CUENTA @"TraerResumenEstadoCuenta"
#define WS_METHOD_TRAER_GRAFICOS_COMPOSICION @"TraerGraficosComposicion"
#define WS_METHOD_TIPO_CAMBIO @"TraerTipoCambio"
#define WS_METHOD_OPERACIONES_EMISOR @"TraerOperacionesEmisor"
#define WS_METHOD_PRECIOS_MERCADO @"TraerPreciosMercado"
// VENCIMIENTOS
#define WS_METHOD_TRAER_VENCIMIENTOS @"TraerVencimientos"
#define WS_METHOD_TRAER_VENCIMIENTO @"TraerDetalleVencimientos"
// BOLETINES
#define WS_METHOD_LISTAR_BOLETINES @"ListarBoletines"
// INSTRUCCIÓN
#define WS_METHOD_LISTAR_INSTRUCCIONES @"ListarInstrucciones"
#define WS_METHOD_OBTENER_INSTRUCCION @"ObtenerInstruccion"
#define WS_METHOD_APROBAR_INSTRUCCION @"AprobarInstruccion"
// CHAT
#define WS_METHOD_TRAER_COMANDOS @"TraerComandos"

// Estilos
#define TINT_NAVIGATION_COLOR @"006837" // Color de tint de los botones del navigation: verde
#define TOP_COLOR @"004976" // Color de fondo del view superior de las pantallas: azul
#define TITLE_COLOR @"004976" // Color del texto de titulo de pantalla de menus: azul
#define SUBTITLE_COLOR @"0AAEDF" // Color del texto de subtitulos de pantalla: celeste
#define TITLE_LIST_COLOR @"004976" // Color del texto del listado de una tabla: azul
#define BORDER_OPTIONS_COLOR @"054E81" // Color del borde de las cajas de menus: pantalla principal, gráficos
#define CONTROL_SELECTOR_COLOR @"0AAEDF" // Color de los control selectors: fecha, moneda
#define LINE_BOTTOM_COLOR @"004976" // Color de la línea inferior de los listados: azul
#define PUBLIC_BUTTON_COLOR @"0071B8" // Color de los botones de la parte pública: celeste



