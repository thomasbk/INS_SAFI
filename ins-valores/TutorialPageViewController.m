//
//  TutorialPageViewController.m
//  INSValores
//
//  Created by Novacomp on 2/20/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "TutorialPageViewController.h"
#import "RequestUtilities.h"

@interface TutorialPageViewController ()

@property (nonatomic, strong) NSMutableArray *contentImages;
@property (nonatomic, strong) NSMutableArray *contentTitles;
@property (nonatomic, strong) NSMutableArray *contentDescriptions;
@property (nonatomic, strong) NSMutableArray *contentColors;

@end

@implementation TutorialPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.dataSource = self;
    [self.view setBackgroundColor:[Functions colorWithHexString:@"FFFFFF"]];
    //[self createPageViewController];
    //[self setupPageControl];
    //[self obtenerInformacion];
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"INFORMACIÓN"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self obtenerInformacion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPageViewController
{
    _contentImages = @[@"logo_safi_2",
                       @"logo_safi_2"];
    
    _contentTitles = @[@"Titulo 1",
                       @"Titulo 2"];
    
    _contentDescriptions = @[@"INS Inversiones es una subsidiaria del Instituto Nacional de Seguros de Costa Rica y es una empresa dedicada a la asesoría especializada y profesional en materia bursátil tanto en el ámbito local e internacional.  Es uno de los puestos de bolsa de mayor patrimonio de la industria bursátil costarricense.", @"INS Inversiones cuenta con una Unidad de Banca de Inversión, la cual tiene como objetivo la estructuración de emisiones para ser colocadas en el Mercado de Valores."];
    
    if([_contentImages count])
    {
        NSArray *startingViewControllers = @[[self itemControllerForIndex:0]];
        [self setViewControllers:startingViewControllers
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
    }
    
    [self didMoveToParentViewController:self];
}

- (void)setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[Functions colorWithHexString:PUBLIC_BUTTON_COLOR]];
    [[UIPageControl appearance] setBackgroundColor:[UIColor clearColor]];
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    TutorialViewController *itemController = (TutorialViewController *)viewController;
    itemController.delegate = self;
    
    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex:itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    TutorialViewController *itemController = (TutorialViewController *)viewController;
    itemController.delegate = self;
    
    if (itemController.itemIndex+1 < [_contentImages count])
    {
        return [self itemControllerForIndex:itemController.itemIndex+1];
    }
    
    
    return nil;
}

- (TutorialViewController *)itemControllerForIndex:(NSUInteger)itemIndex
{
    if (itemIndex < [_contentImages count])
    {
        TutorialViewController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemController"];
        pageItemController.delegate = self;
        pageItemController.itemIndex = itemIndex;
        pageItemController.totalIndex = _contentImages.count;
        pageItemController.imageName = _contentImages[itemIndex];
        pageItemController.tituloSlide = _contentTitles[itemIndex];
        pageItemController.descripcionSlide = _contentDescriptions[itemIndex];
        
        return pageItemController;
    }
    
    return nil;
}


#pragma mark Page Indicator

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [_contentImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Additions

- (NSUInteger)currentControllerIndex
{
    TutorialViewController *pageItemController = (TutorialViewController *) [self currentController];
    pageItemController.delegate = self;
    
    if (pageItemController)
    {
        return pageItemController.itemIndex;
    }
    
    return -1;
}

- (UIViewController *)currentController
{
    if ([self.viewControllers count])
    {
        return self.viewControllers[0];
    }
    
    return nil;
}

// Implement the delegate methods for ChildViewControllerDelegate
- (void)childViewController:(TutorialViewController *)viewController{
    
    // Do something with value...
    
    // ...then dismiss the child view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}






// Obtener los datos de la persona
- (void) obtenerInformacion{
    _alert = [Functions getLoading:@"Obteniendo información"];
    [self presentViewController:_alert animated:YES completion:^{
        
        NSString *url = [RequestUtilities getURL:WS_SERVICE_USUARIO method:WS_METHOD_TRAER_INFORMACION_SITIO];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"I", @"TI", nil];
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
                
                _contentDescriptions = [[NSMutableArray alloc] init];
                _contentImages = [[NSMutableArray alloc] init];
                _contentTitles = [[NSMutableArray alloc] init];
                
                NSArray *textos = [dataString objectForKey:@"Contenido"];
                
                for (NSDictionary *dic in textos) {
                    
                    [_contentDescriptions addObject:[dic objectForKey:@"TX"]];
                    [_contentImages addObject:@"logo_safi_2"];
                    [_contentTitles addObject:@"Titulo 1"];
                    
                }
                
                if([_contentImages count])
                {
                    NSArray *startingViewControllers = @[[self itemControllerForIndex:0]];
                    [self setViewControllers:startingViewControllers
                                   direction:UIPageViewControllerNavigationDirectionForward
                                    animated:NO
                                  completion:nil];
                }
                
                [self didMoveToParentViewController:self];
            }
            
            
            [self setupPageControl];
            
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
