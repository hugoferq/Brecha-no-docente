/*------------------------------------------------------------------------------

Proyecto: 									Brecha de administrativos
Autor: 										Hugo Fernandez y Carlos Ramirez
											UPP
Ultima fecha de modificación:				10/02/2021
Outputs:									Regresiones y graficos para
											determinar el limite del personal de
											limpieza
											
------------------------------------------------------------------------------*/

clear all

*ssc install blindschemes, replace all
set scheme plottig 

*Set paths
global work "D:\Brecha-no-docente"
cd "$work"
global data "D:\OneDrive\Bases de datos\Minedu compartido"

/*----------------------------------------------------------------------------*/

use "Resultados\Base administrativos", clear
keep if clas_digc >=3  //Medianas y grandes
drop if pers_limp_mant == 0 // Lo que queremos predecir es la asignacion dada (optima?)

*Analisis exploratorio
twoway (scatter pers_limp_mant cant_total_2021, xline(2331) xlabel(0(500)4600) xtitle("Matricula del local") ytitle("Personal de limpieza") legend(label(1 "Datos") label(2 "Ajuste lineal") label(3 "Ajuste cuadratico")) ) || (lfit pers_limp_mant cant_total_2021) || (qfit pers_limp_mant cant_total_2021)
graph export "Dispersion outlier.jpg" , as(jpg) name("Graph") quality(90) replace

drop if cant_total_2021 < 2000 & pers_limp_mant > 20
twoway (scatter pers_limp_mant cant_total_2021, xline(2331) xlabel(0(500)4600) xtitle("Matricula del local") ytitle("Personal de limpieza") legend(label(1 "Datos") label(2 "Ajuste lineal") label(3 "Ajuste cuadratico")) ) || (qfit pers_limp_mant cant_total_2021) || (lfit pers_limp_mant cant_total_2021)
graph export "Dispersion sin outlier.jpg" , as(jpg) name("Graph") quality(90) replace

*Variables auxiliares
egen percentiles=xtile(cant_total_2021), n(10) 
egen veintiniles=xtile(cant_total_2021), n(20) 

*Calculo de regresiones
	regress pers_limp_mant c.cant_total_2021##c.cant_total_2021
	outreg2 using "Valores puntuales.doc", title("Model 1") append dec(5)
	margins, at(cant_total_2021 = (0(100)6000))
	marginsplot
	graph export "Marginales.jpg" , as(jpg) name("Graph") quality(90) replace
	
	regress pers_limp_mant c.cant_total_2021##c.cant_total_2021 i.percentiles
	outreg2 using "Valores puntuales.doc", title("Model 2") append dec(5)
	margins, at(cant_total_2021 = (0(100)6000))
	marginsplot
	graph export "Marginales FE.jpg" , as(jpg) name("Graph") quality(90) replace

	regress pers_limp_mant c.cant_total_2021##c.cant_total_2021 i.veintiniles
	outreg2 using "Valores puntuales.doc", title("Model 3") append dec(5)
	margins, at(cant_total_2021 = (0(100)6000))
	marginsplot
	graph export "Marginales FE 5.jpg" , as(jpg) name("Graph") quality(90) replace

/*
Cada vez que agregamos mas Efectos Fijos el estimador converge a la asignacion de 226
*/