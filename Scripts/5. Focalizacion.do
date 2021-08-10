/*------------------------------------------------------------------------------

Proyecto: 									Cierre de brecha de administrativos
Autor: 										Hugo Fernandez y Carlos Ramirez 
											UPP-Minedu
Ultima fecha de modificación:				05/05/2021
Outputs:									Calculo de la brecha del personal 
											administrativo y su costo
											
------------------------------------------------------------------------------*/

clear all
set more off

*Set paths
global work "D:\OneDrive\Trabajo\Minedu\Brecha de administrativos"
global dataminedu "D:\OneDrive\Bases de datos\Minedu"
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
								0) Revisando la propuesta de DIGC
==============================================================================*/

use "$dataminedu\Nexus\2021\nexus_18sira", clear

drop if sitlab == "P" | sitlab == "B" | sitlab == "X" | tiporegistro== "REEMPLAZO" | strpos(estplaza,"BLOQ")
plazaunica

g pers_limp_mant = .
g pers_limp_mant_cas = .
g pers_limp_mant_276 = .
*Trabajador de limpieza y mantenimiento
tokenize `""TRABAJADOR DE SERVICIO" "TRABAJADOR DE SERVICIO I" "TRABAJADOR DE SERVICIO II" "TRABAJADOR DE SERVICIO III" "ARTESANO" "ARTESANO III" "SUPERVISOR DE CONSERVACION Y SERVICIOS" "SUPERVISOR DE CONSERVACION Y SERVICIOS I" "SUPERVISOR DE CONSERVACION Y SERVICIOS II" "PERSONAL DE MANTENIMIENTO" "ARTESANO I" "ARTESANO II" "ELECTRICISTA""'
foreach x of numlist 1(1)13 {
	replace pers_limp_mant = 1 if descargo == "``x''" 
	replace pers_limp_mant_cas = 1 if descargo == "``x''"  & real(codtipotrab)==40
	replace pers_limp_mant_276 = 1 if descargo == "``x''"  & real(codtipotrab)==20
} 
gen pers_limp_mant_n=1==(pers_limp_mant==1 & sitlab == "N")
gen pers_limp_mant_c=pers_limp_mant_n==0 & pers_limp_mant==1

keep if strpos( nivel , "E.B.R.")
collapse (sum) pers_limp_mant*, by(codmod)
ren codmod cod_mod
g anexo = "0"

merge 1:1 cod_mod anexo using "D:\G drive\Bases de datos\Minedu\Padron GG1\Clean\Padron GG1", keep(3) nogen keepusing(codlocal d_gestion d_ges_dep)

collapse (sum) pers_limp_mant* (first) d_gestion d_ges_dep, by(codlocal)

tempfile pea_actual
save `pea_actual'

* Focalizacion de DIGC
import excel using "Bases de datos\20210427_195043_2_DIF_PxQ_Absorcion_2022.xlsx", sheet("Padrón codlocal") firstrow clear

merge 1:1 codlocal using `pea_actual', keep(1 3)

tab PEAS pers_limp_mant
tab PEAS pers_limp_mant_cas
tab PEAS pers_limp_mant_276
tab PEAS 

g observacion = "Ya tienen personal" if pers_limp_mant>=1
export excel using "Resultados\Verificacion de focalizacion.xlsx" if observacion == "Ya tienen personal", sheet("DIF", modify) first(variable)
exit


use "Resultados\Brecha con costo", clear
drop if mi(descreg)
hashsort descreg d_prov d_dist

*Focalizacion
	keep if rural_upp_2020 == 500 | rural_upp_2020 == 100 
	keep if caso_covid<=10 

export excel using ".xlsx", sheet("Focalizado", modify) cell(A3)  firstrow(variable)


