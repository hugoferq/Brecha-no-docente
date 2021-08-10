/*------------------------------------------------------------------------------

Proyecto: 									Identificación de curvatura
Autor: 										Hugo Fernandez y Carlos Ramirez-Racionalización-UPP
Ultima fecha de modificación:				04/01/2021
Outputs:									Regresiones y graficos
											
------------------------------------------------------------------------------*/

clear all

*ssc install blindschemes, replace all
set scheme plottig 

global work "D:\G drive\Investigación\Minedu\Brecha de administrativos"
global resultados "$work\Resultados"

cd "$resultados"

/*----------------------------------------------------------------------------*/

use "$resultados\Base administrativos", clear
keep if clas_digc >=3  //Medianas y grandes
drop if pers_limp_mant == 0 // Lo que queremos predecir es la asignacion dada (optima?)

*Analisis exploratorio
twoway (scatter pers_limp_mant cant_alum_2020, xline(2331) xlabel(0(500)4600) xtitle("Matricula del local") ytitle("Personal de limpieza") legend(label(1 "Datos") label(2 "Ajuste lineal") label(3 "Ajuste cuadratico")) ) || (lfit pers_limp_mant cant_alum_2020) || (qfit pers_limp_mant cant_alum_2020)
graph export "Dispersion outlier.jpg" , as(jpg) name("Graph") quality(90) replace

drop if cant_alum_2020 < 2000 & pers_limp_mant > 20
twoway (scatter pers_limp_mant cant_alum_2020, xline(2331) xlabel(0(500)4600) xtitle("Matricula del local") ytitle("Personal de limpieza") legend(label(1 "Datos") label(2 "Ajuste lineal") label(3 "Ajuste cuadratico")) ) || (qfit pers_limp_mant cant_alum_2020) || (lfit pers_limp_mant cant_alum_2020)
graph export "Dispersion sin outlier.jpg" , as(jpg) name("Graph") quality(90) replace

*Variables auxiliares
egen percentiles=xtile(cant_alum_2020), n(10) 
egen veintiniles=xtile(cant_alum_2020), n(20) 

*Calculo de regresiones
	regress pers_limp_mant c.cant_alum_2020##c.cant_alum_2020
	outreg2 using "Valores puntuales.doc", title("Model 1") append dec(5)
	margins, at(cant_alum_2020 = (0(100)6000))
	marginsplot
	graph export "Marginales.jpg" , as(jpg) name("Graph") quality(90) replace
	
	regress pers_limp_mant c.cant_alum_2020##c.cant_alum_2020 i.percentiles
	outreg2 using "Valores puntuales.doc", title("Model 2") append dec(5)
	margins, at(cant_alum_2020 = (0(100)6000))
	marginsplot
	graph export "Marginales FE.jpg" , as(jpg) name("Graph") quality(90) replace

	regress pers_limp_mant c.cant_alum_2020##c.cant_alum_2020 i.veintiniles
	outreg2 using "Valores puntuales.doc", title("Model 3") append dec(5)
	margins, at(cant_alum_2020 = (0(100)6000))
	marginsplot
	graph export "Marginales FE 5.jpg" , as(jpg) name("Graph") quality(90) replace

/*
Cada vez que agregamos mas Efectos Fijos el estimador converge a la asignacion de 226
*/