/*------------------------------------------------------------------------------

Proyecto: 									Brecha de administrativos
Autor: 										Hugo Fernandez - Carlos Ramirez 
											UPP-Minedu
Ultima fecha de modificación:				19/08/2021
Outputs:									Calculo de la brecha del personal 
											administrativo y su costo
											
------------------------------------------------------------------------------*/

clear all
set more off

*Set paths
global work "D:\Brecha-no-docente"
global data "D:\OneDrive\Bases de datos\Minedu compartido"
cd "$work"

/*----------------------------------------------------------------------------*/

program plazaunica

 ** Identificación de la plaza original y sus espejo **
		
 		gen prior_tipo = 1
		replace prior_tipo = 2 if tiporegistro == "EVENTUAL"
		replace prior_tipo = 3 if tiporegistro == "PROYECTO"
		replace prior_tipo = 4 if tiporegistro == "CUADRO DE HORAS"
		replace prior_tipo = 5 if tiporegistro == "REEMPLAZO"
		
	 	gen prior_sitlab = 1
		replace prior_sitlab = 2 if sitlab == "F" | sitlab == "D" | sitlab == "E"  | sitlab == "T"
		replace prior_sitlab = 3 if sitlab == "C" | sitlab == "V"
		
		gen soplaza = !strpos(estplaza,"SG") & !strpos(estplaza,"CG") & !strpos(estplaza,"ABAND") //toma valor 1 si la plaza no tiene licencia sin goce, con goce o es una plaza abandonada 
		gen sestpla = estplaza == "ACTIV" //toma valor 1 si es activo
		hashsort -jornlab, gen(sjornlb) //ordenamiento ascendente
		gen socupp = mi(numdocum) //toma valor 1 si tiene dni 
		
		*Priorización de plazas activas con personal
		
		duplicates tag descreg nombreooii codmod codplaza, g(dupli)
		
		bys descreg nombreooii codmod codplaza (prior_tipo - socupp): gen tipo_fin = _n  
       
		label define tipo_fin 1"Plaza original" 2"Plaza espejo 1" 3"Plaza espejo 2" 4"Plaza espejo 3" 5"Plaza espejo 4"
		label values tipo_fin tipo_fin		
		
tab tipo_fin dupli
	keep if tipo_fin==1
tab tipo_fin dupli

end

/*==============================================================================
	Focalizacion 1: Dar 1 personal de limpieza a los locales que no tienen 
--------------------------------------------------------------------------------

1) Inlcuyo personal de limpieza y mantenimiento de otras modalidades
2) Identifico a los locales de EBR con mas de 140 alumnos
3) Costeo

==============================================================================*/

*1) Inlcuyo personal de limpieza y mantenimiento de otras modalidades
 
use "$data\Nexus\2021\nexus_30sira", clear

drop if /*sitlab == "P" | sitlab == "X" |*/ sitlab == "B" | tiporegistro== "REEMPLAZO" | strpos(estplaza,"BLOQ") //Plazas que no son relevantes para este analisis

keep if strpos(nivel, "E.B.A.") | strpos(nivel, "E.B.R.") | strpos(nivel, "ESPECIAL")

plazaunica

g pers_limp_mant = 0

tokenize `""TRABAJADOR DE SERVICIO" "TRABAJADOR DE SERVICIO I" "TRABAJADOR DE SERVICIO II" "TRABAJADOR DE SERVICIO III" "ARTESANO" "ARTESANO III" "SUPERVISOR DE CONSERVACION Y SERVICIOS" "SUPERVISOR DE CONSERVACION Y SERVICIOS I" "SUPERVISOR DE CONSERVACION Y SERVICIOS II" "PERSONAL DE MANTENIMIENTO" "ARTESANO I" "ARTESANO II" "ELECTRICISTA""'
foreach x of numlist 1(1)13 {
	replace pers_limp_mant = 1 if descargo == "``x''" 
} 

gen pers_limp_mant_n=1==(pers_limp_mant==1 & sitlab == "N")
gen pers_limp_mant_c=pers_limp_mant_n==0 

collapse (sum) pers_limp_mant_exp = pers_limp_mant, by(codmod)
ren codmod cod_mod
merge 1:m cod_mod using "$data\Padron GG1", keep(3)
collapse (sum) pers_limp_mant_exp = pers_limp_mant, by(codlocal)

tempfile limpieza_exp
save `limpieza_exp'

*2) Identifico a los locales de EBR con mas de 140 alumnos
use "Resultados\Base administrativos", clear
keep if clas_digc >=3
merge 1:1 codlocal using `limpieza_exp', keep(3)

keep if pers_limp_mant == 0 | pers_limp_mant_exp == 0 

*3) Costeo

global sueldo_pers_limp_mant "1150"  
gen salario_pers_limp_mant = 12*${sueldo_pers_limp_mant} + 600 + 12*min(${sueldo_pers_limp_mant}*0.09,4500*0.55*0.09)
gen costo_pers_limp_mant_foc = ceil(salario_pers_limp_mant)

tabstat costo_pers_limp_mant , stat(sum) format(%-12.0fc)

*Variables a presentar
global datos_generales "codlocal nombreooii	d_dpto d_prov d_dist ubigeo region pliego codue	unidadejecutora	nombentidad	codooii	tipo_entidad clas_digc	cant_total_2021	redes jec_2020 turno integracion rural_upp_2021"
global personal_existente "coord_adm_ie_n coord_adm_ie_c oficinista_n oficinista_c pers_limp_mant_n pers_limp_mant_c pers_vigilancia_n pers_vigilancia_c secretario_n secretario_c coord_adm_ie	oficinista	pers_limp_mant	pers_vigilancia	secretario"
global personal_optimo "opt_coord_adm_ie opt_oficinista	opt_pers_limp_mant opt_pers_vigilancia opt_secretario"
global brecha "exd_coord_adm_ie req_coord_adm_ie exd_oficinista req_oficinista	exd_pers_limp_mant req_pers_limp_mant	exd_pers_vigilancia	req_pers_vigilancia	exd_secretario req_secretario" 
global costo_actual "costo_actual_coord_adm_ie costo_actual_oficinista costo_actual_pers_limp_mant costo_actual_pers_vigilancia	costo_actual_secretario"
global costo_optimo "costo_opt_coord_adm_ie costo_opt_oficinista costo_opt_pers_limp_mant costo_opt_pers_vigilancia costo_opt_secretario" 
global costo_req "costo_brecha_pers_limp_mant" 

hashsort region d_prov d_dist
order ${datos_generales} costo_pers_limp_mant_foc

export excel ${datos_generales} costo_pers_limp_mant_foc using "Resultados\Brecha personal administrativo.xlsx", sheet("Focalizacion Limpieza", modify) cell(A1)  firstrow(variable)