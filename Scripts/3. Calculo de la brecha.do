/*------------------------------------------------------------------------------

Proyecto: 									Brecha de administrativos
Autor: 										Hugo Fernandez - Carlos Ramirez 
											UPP
Ultima fecha de modificación:				10/08/2021
Outputs:									Brecha de administrativos
											
------------------------------------------------------------------------------*/

clear all
set more off

*Set paths
global work "D:\Brecha-no-docente"
cd "$work"
global data "D:\OneDrive\Bases de datos\Minedu compartido"

use "Resultados\Base administrativos", clear
drop aux_* edad_aux* // Dropero todos los auxilares porque no fueron aprobados por UPP
/*------------------------------------------------------------------------------

								I) Micro y Pequena

Personal requerido:
    1.1) Coordinador administrativo de Red									

------------------------------------------------------------------------------*/


*1.1) Coordinador administrativo de Red
	gen opt_coord_adm_red = 1 if redes!=0 & (clas_digc==1 |  clas_digc==2)
	drop opt_coord_adm_red //Evaluar por separado
	drop if clas_digc==1 |  clas_digc==2

/*------------------------------------------------------------------------------

								II) Mediana

Personal requerido:
    2.1) Coordinador administrativo 
	2.2) Oficinista
	2.3) Personal de limpieza y mantenimiento
	2.4) Personal de vigilancia

------------------------------------------------------------------------------*/

*2.1) Coordinador administrativo 
	gen opt_coord_adm_ie = 1 if clas_digc==3 
	
*2.2) Oficinista
	gen opt_oficinista = 1 if clas_digc==3 & cant_total_2021>=450
	
*2.3) Personal de limpieza y mantenimiento	
	gen opt_pers_limp_mant = ceil(cant_total_2021/226) if clas_digc==3  
	replace opt_pers_limp_mant = 16 if clas_digc==3 & opt_pers_limp_mant > 16
	*table opt_pers_limp_mant , c(min cant_total_2021  max cant_total_2021)
	
*2.4) Personal de vigilancia
	gen opt_pers_vigilancia = turno if clas_digc==3
	replace opt_pers_vigilancia = opt_pers_vigilancia + 1 if inicial!=0 & clas_digc==3 

/*------------------------------------------------------------------------------

							III) Grande

Personal requerido:
    3.1) Coordinador administrativo 
	3.2) Oficinista
	3.3) Secretario
	3.4) Personal de limpieza y mantenimiento
	3.5) Personal de vigilancia

------------------------------------------------------------------------------*/	
	
*3.1) Coordinador administrativo 
	replace opt_coord_adm_ie = 1 if clas_digc==4 

*3.2) Oficinista
	replace opt_oficinista = ceil(cant_total_2021/450) if clas_digc==4 
	replace opt_oficinista = 3 if clas_digc==4 & opt_oficinista > 3
	
*3.3) Secretario
	gen opt_secretario = 1 if clas_digc==4 & cant_total_2021 > 1050
	
*3.4) Personal de limpieza y mantenimiento
	replace opt_pers_limp_mant = ceil(cant_total_2021/226) if clas_digc==4  
	replace opt_pers_limp_mant = 16 if clas_digc==4 & opt_pers_limp_mant > 16
	*table opt_pers_limp_mant , c(min cant_total_2021  max cant_total_2021)
		
*3.5) Personal de vigilancia
	replace opt_pers_vigilancia = turno if clas_digc==4
	replace opt_pers_vigilancia = opt_pers_vigilancia + 1 if inicial!=0 & clas_digc==4 

/*------------------------------------------------------------------------------
					IV) Locales con equipamiento
------------------------------------------------------------------------------*/

/*Auxiliar de biblioteca
gen opt_aux_biblioteca = 1 if biblio_op==1
replace opt_aux_biblioteca=0 if opt_aux_biblioteca==.*/

/*Auxiliar de laboratorio
gen opt_aux_laboratorio =1 if laboratorio==1
replace opt_aux_laboratorio=0 if opt_aux_laboratorio==.*/

/*Auxiliar de sistemas
gen opt_aux_sistemas = 1 if cant_pc>15	
replace opt_aux_sistemas=0 if opt_aux_sistemas==.*/

/*Calculo de la brecha*/
local optimos "opt_coord_adm_ie opt_oficinista opt_pers_limp_mant opt_pers_vigilancia opt_secretario"
foreach x of local optimos {
    replace `x' = 0 if mi(`x')
} 

foreach x in coord_adm_ie oficinista pers_limp_mant pers_vigilancia secretario /*aux_biblioteca aux_laboratorio aux_sistemas*/ {
	
	gen temp_brecha_`x' = opt_`x' - `x'  
	gen req_`x' = temp_brecha_`x' if temp_brecha_`x' >=0
	gen exd_`x' = abs(temp_brecha_`x') if temp_brecha_`x' <=0
	
	replace req_`x' = 0 if mi(req_`x')
	replace exd_`x' = 0 if mi(exd_`x')
	
}
drop gestion d_gestion ges_dep d_ges_dep  talumno tseccion

order codlocal nombreooii d_dpto d_prov d_dist ubigeo region pliego codue unidadejecutora nombentidad codooii tipo_entidad clas_digc clas_digc cant_total_2021 redes jec_2020 turno integracion rural_upp_2021 //Datos generales

order coord_adm_ie_n oficinista_n pers_limp_mant_n pers_vigilancia_n secretario_n /*aux_biblioteca_n aux_laboratorio_n aux_sistemas_n*/, after(rural_upp_2021) //Datos de personal actual nombrado

foreach x in coord_adm_ie oficinista pers_limp_mant pers_vigilancia secretario /*aux_biblioteca aux_laboratorio aux_sistemas*/ {
	order `x'_c, after(`x'_n) //Datos de personal contratado
}

order coord_adm_ie oficinista pers_limp_mant pers_vigilancia secretario /*aux_biblioteca aux_laboratorio aux_sistemas*/, after(secretario_c) //Datos del personal

order opt_coord_adm_ie opt_oficinista opt_pers_limp_mant opt_pers_vigilancia opt_secretario /*opt_aux_biblioteca opt_aux_laboratorio opt_aux_sistemas*/, after(secretario) // Datos del personal optimo

order exd_coord_adm_ie exd_oficinista exd_pers_limp_mant exd_pers_vigilancia exd_secretario /*exd_aux_biblioteca exd_aux_laboratorio  exd_aux_sistemas*/, after(opt_secretario) //Datos de la brecha excedente
foreach x in coord_adm_ie oficinista pers_limp_mant pers_vigilancia secretario /*aux_biblioteca aux_laboratorio  aux_sistemas*/  {
	order req_`x', after(exd_`x') //Datos de la brecha requerido
}

drop psicologo* edad_psicologo_n inicial secundaria temp_brecha_*

/*------------------------------------------------------------------------------

					Costeo de la Brecha sin movimiento

------------------------------------------------------------------------------*/

global sueldo_coord_adm_red "2500"
global sueldo_coord_adm_ie "1800"
global sueldo_oficinista "1200"
global sueldo_secretario "1400"
*global sueldo_aux_biblioteca "1150"
*global sueldo_aux_laboratorio "1150"
*global sueldo_aux_sistemas "1150"
global sueldo_pers_limp_mant "1150"
global sueldo_pers_vigilancia "1150"

foreach x in coord_adm_ie oficinista pers_limp_mant pers_vigilancia secretario /*aux_biblioteca aux_laboratorio aux_sistemas*/ {
  
    gen salario_`x' = 12*${sueldo_`x'} + 600 + 12*min(${sueldo_`x'}*0.09,4500*0.55*0.09)
  
	gen costo_actual_`x' = ceil(salario_`x')*`x'
	gen costo_opt_`x' = ceil(salario_`x')* opt_`x'  
	gen costo_brecha_`x' = ceil(salario_`x')*req_`x'
}

drop salario_* 

*Variables a presentar
global datos_generales "codlocal nombreooii	d_dpto d_prov d_dist ubigeo region pliego codue	unidadejecutora	nombentidad	codooii	tipo_entidad clas_digc	cant_total_2021	redes jec_2020 turno integracion rural_upp_2021"
global personal_existente "coord_adm_ie_n coord_adm_ie_c oficinista_n oficinista_c pers_limp_mant_n pers_limp_mant_c pers_vigilancia_n pers_vigilancia_c secretario_n secretario_c coord_adm_ie	oficinista	pers_limp_mant	pers_vigilancia	secretario"
global personal_optimo "opt_coord_adm_ie opt_oficinista	opt_pers_limp_mant opt_pers_vigilancia opt_secretario"
global brecha "exd_coord_adm_ie req_coord_adm_ie exd_oficinista req_oficinista	exd_pers_limp_mant req_pers_limp_mant	exd_pers_vigilancia	req_pers_vigilancia	exd_secretario req_secretario" 
global costo_actual "costo_actual_coord_adm_ie costo_actual_oficinista costo_actual_pers_limp_mant costo_actual_pers_vigilancia	costo_actual_secretario"
global costo_optimo "costo_opt_coord_adm_ie costo_opt_oficinista costo_opt_pers_limp_mant costo_opt_pers_vigilancia costo_opt_secretario" 
global costo_req "costo_brecha_coord_adm_ie costo_brecha_oficinista costo_brecha_pers_limp_mant costo_brecha_pers_vigilancia	costo_brecha_secretario" 

hashsort region d_prov d_dist
order ${datos_generales} ${personal_existente} ${personal_optimo} ${brecha} ${costo_actual} ${costo_optimo} ${costo_req}

export excel ${datos_generales} ${personal_existente} ${personal_optimo} ${brecha} ${costo_actual} ${costo_optimo} ${costo_req} using "Resultados\Brecha personal administrativo.xlsx", sheet("Resultados ie", modify) cell(A4)  firstrow(variable)
save "Resultados\Brecha con costo", replace

/*------------------------------------------------------------------------------

					Costeo de la Brecha con movimiento

------------------------------------------------------------------------------*/

use "Resultados\Brecha con costo", clear

keep region pliego codue unidadejecutora tipo_entidad nombentidad codooii  pers_limp_mant pers_limp_mant_c pers_limp_mant_n req_pers_limp_mant exd_pers_limp_mant

egen exd_pers_limp_mant_c = rowmin(exd_pers_limp_mant pers_limp_mant_c)
g exd_pers_limp_mant_n = exd_pers_limp_mant - exd_pers_limp_mant_c 

collapse (sum) exd_pers_limp_mant_n exd_pers_limp_mant exd_pers_limp_mant_c req_pers_limp_mant , by(region pliego nombentidad codooii)

* Brecha con nombrados que no se puden mover
g brecha_ugel= (exd_pers_limp_mant_c) - req_pers_limp_mant

collapse (sum) exd_pers_limp_mant_n exd_pers_limp_mant exd_pers_limp_mant_c req_pers_limp_mant brecha_ugel , by(region pliego)

export excel using "Resultados\Brecha personal administrativo.xlsx", sheet("Brecha-Racio", modify) first(variable)
