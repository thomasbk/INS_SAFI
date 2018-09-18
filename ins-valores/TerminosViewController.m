//
//  TerminosViewController.m
//  INSValores
//
//  Created by Novacomp on 5/2/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "TerminosViewController.h"
#import "RequestUtilities.h"

@interface TerminosViewController ()

@end

@implementation TerminosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Titulo
    self.tituloPantalla.textColor = [Functions colorWithHexString:PUBLIC_BUTTON_COLOR];
    
    // Scroll view
    self.scrollView.lastView = nil;
    self.scrollView.penultimateView = nil;
    self.scrollView.delegate = self;
    self.scrollView.layer.borderWidth = 1;
    self.scrollView.layer.borderColor = [Functions colorWithHexString:@"004976"].CGColor;
    
    // Botón aceptar
    [Functions redondearView:self.botonAceptar Color:PUBLIC_BUTTON_COLOR Borde:1.0f Radius:15.0f];
    [self.botonAceptar setBackgroundColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    
    // Bottom view
    self.bottomView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
    /*
    // Párrafos de términos
    [self agregarParrafo:@"ANTES DE ACCEDER A LA APLICACIÓN, POR FAVOR, LEA DETENIDAMENTE LO SIGUIENTE: Este acuerdo de acceso y uso de la aplicación móvil de INS Inversiones, en adelante INS Inversiones, es un contrato entre usted, en adelante denominado El Cliente (ya sea una persona física o la entidad jurídica a la que representa), e INS Valores, el cual determina las condiciones en las cuales INS Valores ofrece información y El Cliente la accede y utiliza."];
    [self agregarParrafo:@"El acceso y uso de la aplicación móvil que INS Valores pone a disposición de los clientes a través del Google Play implica la aceptación de todas las condiciones incluidas en este Acuerdo, INS Valores podrá modificar estos Términos y Condiciones sin necesidad de previo aviso por parte de INS Valores."];
    [self agregarParrafo:@"La información que INS Valores brinda a El Cliente mediante esta aplicación y cualquier otro medio, está constituida tanto de información pública como privada, la cual se obtuvo de fuentes consideradas confiables, pero no se garantiza su exactitud, veracidad u objetividad, esta información es para uso y distribución exclusivo de los clientes de INS Valores."];
    [self agregarParrafo:@"A través de la aplicación de INS Valores usted podrá, visualizar y acceder a la siguiente información, con el fin de mantenerse informado de las inversiones que realiza a través de INS Valores, así como de información relevante para sus decisiones de inversión:"];
    [self agregarParrafo:@"1. Cartera: en esta opción tendrá acceso a los título valores que componen su cartera de inversión y que se encuentran bajo la custodia de INS Valores, esta opción está disponible únicamente para los Clientes que han contrato los servicios de custodia de valores con INS Valores."];
    [self agregarParrafo:@"La opción Cartera le permite visualizar el estado de sus inversiones al día de la consulta, utilizando diferentes parámetros de clasificación como mercado, moneda, calificación de riesgo y emisor. De igual forma podrá visualizar el rendimiento histórico de su cartera."];
    [self agregarParrafo:@"2. Vencimiento: esta opción permite al Cliente, visualizar los vencimientos de cupones relacionados a los títulos valores que mantiene en custodia con INS Valores."];
    [self agregarParrafo:@"3. Inversiones: a través de esta opción el Cliente podrá girar instrucciones a INS Valores para que por cuenta de él y de conformidad con las condiciones establecidas en el Contrato General de Comisión para la Realización de Operaciones Bursátiles y Servicios Complementarios y Conexos, INS Valores ejecute operaciones bursátiles; para tales efectos el Cliente manifiesta conocer y aceptar que el uso de esta aplicación se reputa como un medio de comunicación oficial de comunicación y todos las operaciones que se aprueben a través de ésta aplicación serán su responsabilidad."];
    [self agregarParrafo:@"4. Contacto: podrá contactar al Corredor de Bolsa, asignado por INS Valores para brindarle asesoría, en relación su perfil y política de inversión."];
    [self agregarParrafo:@"5. Boletines: en esta opción encontrará información general que INS Valores prepara para mantener a sus clientes actualizados en relación al mercado de valores y los títulos valores que mantiene en custodia con INS Valores, por lo que no deberá considerarse como una oferta para comprar, vender o suscribir valores u otros instrumentos financieros, razón por la cual, INS Valores no se hace responsable por el uso, distribución o interpretación que se le dé a la misma, ni tampoco por ningún error u omisión en la información contenida en esa sección de la aplicación, así como en caso de pérdidas que surjan del uso directo o indirecto de la información presentada en las mismas. Adicionalmente como parte de la asesoría de inversión que INS Valores brinda a sus clientes, en ésta opción el Cliente tendrá acceso a los Hechos Relevantes, emitidos por los emisores de los títulos valores que mantiene en custodia con INS Valores."];
    [self agregarParrafo:@"Es obligación del Cliente comunicar de forma inmediata a INS Valores, a través de su corredor de bolsa asignado, cualquier inexactitud entre la información a la que tiene acceso a través de ésta aplicación y la que le haga llegar INS Valores, a través del Estado de Cuenta o los medios oficiales de comunicación, así como si se presenta información que no corresponde a los títulos valores que mantiene en custodia con INS Valores."];
    [self agregarParrafo:@"INS Valores toma las medidas técnicas y organizativas necesarias para prevenir el acceso o divulgación de su información personal de un modo no autorizado. Sin embargo, no garantiza que se pueda evitar cualquier posible uso indebido de su información personal. El Cliente es responsable de custodiar y no revelar su contraseña para evitar el acceso y uso no autorizados a ésta aplicación. INS Valores solicita que no comparta la contraseña con nadie. Recuerde desactivar la opción de “Guardar contraseña” antes de ingresar a la sección privada, cuando comparte su equipo de acceso a un tercero, o incluso si lo devuelve a una tienda o lo envía a reparar, además, recuerde siempre finalizar su sesión cuando termina de acceder al sitio privado de INS Valores."];
    [self agregarParrafo:@"No se podrá desensamblar ni descompilar la aplicación de INS Valores, ni llevar a cabo un proceso de ingeniería inversa, con la única excepción de que el permiso para hacerlo lo consienta la ley aplicable."];
    [self agregarParrafo:@"INS Valores pone en práctica medidas de seguridad que se corresponden con las mejores prácticas actuales para proteger ésta aplicación, entre las mismas figuran medidas técnicas, de procedimiento, de supervisión y ubicación, con el propósito de proteger los datos contra el uso indebido, acceso o divulgación no autorizados, pérdida, alteración o destrucción, por lo cual, se prohíbe cualquier tipo de actividad malicioso en contra de la aplicación o por medio de la misma, tal como la propagación de cualquier tipo de malware o ataque informático."];
    [self agregarParrafo:@"INS Valores se reserva todos los derechos que no se han otorgado expresamente en este acuerdo de uso y se reserva el derecho de modificar, suspender, cancelar o restringir el contenido de la aplicación o la información obtenida a través de ella, sin necesidad de previo aviso."];
    [self agregarParrafo:@"La información contenida en la aplicación no puede ser difundida, reproducida o compartida sin autorización previa de INS Inversiones."];
    [self agregarParrafo:@"De acuerdo con la Ley 7732, artículo 13, la autorización para realizar oferta pública no implica calificación sobre la bondad de la emisión ni la solvencia del emisor o intermediario. Las personas involucradas en la elaboración de la información contenida en esta aplicación no presentan conflicto de interés."];
    [self agregarParrafo:@"USO DE TOUCH ID: "]; // Se deja un espacio para evitar problemas al ser solo una línea
    [self agregarParrafo:@"El Cliente podrá optar por ingresar a esta aplicación a través de la funcionalidad de huella digital, utilizando el sistema Touch ID, que se encuentra disponible para los dispositivos Apple; en estos casos el Cliente deberá, previo a habilitar dicha ingreso, activar y configurar ésta funcionalidad en su dispositivo Apple."];
    */
    
    
}

// Agrega un párrafo
-(void) agregarParrafo:(NSString *) parrafo{
    
    NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
    paragraphStyles.alignment = NSTextAlignmentJustified;      //justified text
    paragraphStyles.firstLineHeadIndent = 1.0;                //must have a value to make it work
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles};
    
    float scrollConstraint = self.leadingScrollConstraint.constant + self.trailingScrollConstraint.constant;
    
    UIView *terminosView = [[UIView alloc] initWithFrame:CGRectZero];
    terminosView.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *terminos = [[UILabel alloc] initWithFrame:CGRectMake(10,10,[[UIScreen mainScreen] bounds].size.width-scrollConstraint-20,0)];
    [terminos setNumberOfLines:0];
    [terminos setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    terminos.text = parrafo;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString: terminos.text attributes: attributes];
    terminos.attributedText = attributedString;
    [terminos sizeToFit];
    [terminosView addSubview:terminos];
    CGRect frameView = terminosView.frame;
    frameView.size.height = terminos.frame.size.height + 10;
    terminosView.frame = frameView;
    [self.scrollView agregarObjetoAScrollView:terminosView];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"TÉRMINOS"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self obtenerTerminos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Clic botón de aceptar los términos
- (IBAction)clicAceptar:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}




// Obtener los datos de la persona
- (void) obtenerTerminos{
    _alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:_alert animated:YES completion:^{
        
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_INFORMACION_SITIO];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"T", @"TI", nil];
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:params, @"pConsulta", nil];
        NSDictionary *paramsExtern = [[NSDictionary alloc] initWithObjectsAndKeys:[RequestUtilities jsonCast:data], @"pJsonString", nil];
        NSDictionary *dataExtern = [[NSDictionary alloc] initWithDictionary:paramsExtern];
        [RequestUtilities asynPutRequest:url withData:dataExtern delegate:self];
    }];
    
}

// Finalización del request al webservice
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [self closeAlertLoading];
    
    NSURL *url = [request originalURL];
    NSArray *comp = [url pathComponents];
    NSString *method = [comp objectAtIndex:4];
    NSDictionary *data;
    
    NSString* newStrAll = [RequestUtilities getStringFromRequest:request];
    NSData* dataJson = [newStrAll dataUsingEncoding:NSUTF8StringEncoding];
    data = [NSJSONSerialization JSONObjectWithData:dataJson options:0 error:nil];
    if(data != nil){
        if ([method isEqualToString:WS_METHOD_TRAER_INFORMACION_SITIO])
        {
            NSString *result = [data objectForKey:@"TraerInformacionSitioResult"];
            NSData* dataJsonString = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataString = [NSJSONSerialization JSONObjectWithData:dataJsonString options:0 error:nil];
            
            dataString = [dataString objectForKey:@"Resultado"];
            
            NSString *cod = [NSString stringWithFormat:@"%@",[[dataString objectForKey:@"Respuesta"] objectForKey:@"CodMensaje"]];
            
            if ([cod isEqualToString:@"0"])
            {
                NSArray *textos = [dataString objectForKey:@"Contenido"];
                
                for (NSDictionary *dic in textos) {
                    [self agregarParrafo:[dic objectForKey:@"TX"]];
                }
                
            }
            
            [self.scrollView closeLayout];
            
        }
    } else {
        // Cerramos el alert de loading
        [self closeAlertLoading];
        [self showAlert:@"Términos" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:false];
    }
}

// Fallo en el request al webservice
- (void)requestFailed:(ASIHTTPRequest *)request {
    // Cerramos el alert de loading
    [self closeAlertLoading];
    [self showAlert:@"Términos" withMessage:@"Ha ocurrido un error con la solicitud" withReturn:false];
}


#pragma mark - showAlert
- (void)showAlert:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController *alert = [Functions getAlert:title withMessage:message withActions:actions];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message withReturn:(Boolean)returnPage{
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if(returnPage){
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
    
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    if(!self.alert.isBeingPresented){
        self.alert = [Functions getAlert:title withMessage:message withActions:actions];
        [self presentViewController:self.alert animated:YES completion:nil];
    }
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertAction *btnAceptar = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    
    [btnAceptar setValue:[Functions colorWithHexString:TITLE_COLOR] forKey:@"titleTextColor"];
    NSArray *actions = [[NSArray alloc] initWithObjects:btnAceptar, nil];
    
    if(!self.alert.isBeingPresented){
        self.alert = [Functions getAlert:title withMessage:message withActions:actions];
        [self presentViewController:self.alert animated:YES completion:nil];
    }
}


- (void)closeAlertLoading {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
