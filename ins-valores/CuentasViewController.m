//
//  CuentasViewController.m
//  INSValores
//
//  Created by Novacomp on 3/14/17.
//  Copyright © 2017 Novacomp. All rights reserved.
//

#import "CuentasViewController.h"
#import "AppDelegate.h"

@interface CuentasViewController ()

@end

@implementation CuentasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Top view
    self.topView.backgroundColor = [Functions colorWithHexString:TOP_COLOR];
    
    // Logo del navigation
    [Functions putNavigationIcon:self.navigationItem];
    
    // Tint de right buttom
    self.navigationItem.rightBarButtonItem.tintColor = [Functions colorWithHexString:@"006837"];
    
    // Es necesario para el correcto centrado del logo del navigation
    [self.navigationItem.leftBarButtonItem setEnabled:false];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    
    User *user = [User getInstance];
    self.cuentas = [user getCuentas];
    if([self.cuentas count] < 3){
        // Agregamos imagen en la parte de abajo de la tabla
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        CGRect positionImage = bgImageView.frame;
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        float topRestar = self.navigationController.navigationBar.frame.size.height + rectStatus.size.height;
        CGRect newPosition = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-positionImage.size.height-topRestar, [[UIScreen mainScreen] bounds].size.width, positionImage.size.height);
        bgImageView.frame = newPosition;
        
        [self.view addSubview:bgImageView];
        [self.view sendSubviewToBack:bgImageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    // GOOGLE ANALYTICS
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:@"&cd" value:@"CUENTAS"];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - <UITableViewDataSource>
// Número de secciones de la tabla
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Número de celdas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.cuentas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cuenta_cell_iphone";
    
    CuentasCell *cell = (CuentasCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CuentasCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Cuenta *cuenta = [self.cuentas objectAtIndex:indexPath.row];
    cell.nombreCuenta.text = cuenta.cNombre;
    cell.idCuenta.text = cuenta.cId;
    cell.rolCuenta.text = cuenta.cRol;
    
    // Ajustamos el view que contiene los elementos para mantenerlo centrado
    float titConstraints = cell.leadingViewConstraint.constant + cell.trailingViewConstraint.constant;
    CGRect frameTit = cell.nombreCuenta.frame;
    frameTit.size.width = [[UIScreen mainScreen] bounds].size.width-titConstraints;
    cell.nombreCuenta.frame = frameTit;
    [cell.nombreCuenta sizeToFit];
    
    float tam = cell.nombreCuenta.frame.size.height + cell.idCuenta.frame.size.height + cell.rolCuenta.frame.size.height - 8;
    if(cell.heightViewConstraint.constant != tam){
        cell.heightViewConstraint.constant = tam;
    }
    
    return cell;
}

// Tamaño de la celda
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cuenta_cell_iphone";
    
    CuentasCell *cell = (CuentasCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CuentasCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell.frame.size.height;
}

// Selección de una celda
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewController *pantallaPrincipal = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
    Cuenta *cuenta = [self.cuentas objectAtIndex:indexPath.row];
    pantallaPrincipal.cuenta = cuenta;
    [self.navigationController pushViewController:pantallaPrincipal animated:true];
}

// Clic botón de salir: mata el token y envia a pantalla de login
- (IBAction)clicSalir:(id)sender {
    [Functions cerrarSesion:self.navigationController withService:true];
}

@end
