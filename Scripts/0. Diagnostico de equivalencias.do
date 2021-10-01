/*------------------------------------------------------------------------------

Proyecto: 									Brecha de administrativos
Autor: 										Hugo Fernandez - Carlos Ramirez 
											UPP
Ultima fecha de modificación:				09/08/2021
Outputs:									Equivalencias de cargos antiguos
											con los nuevos cargos
											
------------------------------------------------------------------------------*/

clear all
set more off

*Set paths
global work "D:\Brecha-no-docente"
cd "$work"
global data "D:\OneDrive\Bases de datos\Minedu compartido"
cap mkdir "Resultados"

*Programs
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

/*----------------------------------------------------------------------------*/

use "$data\Nexus\2021\nexus_30sira", clear

drop if /*sitlab == "P" | sitlab == "X" |*/ sitlab == "B" | tiporegistro== "REEMPLAZO" | strpos(estplaza,"BLOQ") //Plazas que no son relevantes para este analisis

keep if strpos(nivel, "E.B.R" ) // Nivel relevante para este analisis

plazaunica

*Psicologo
gen plaza_administrativa = 1 if descargo=="ASISTENTE SOCIAL" | descargo=="ASISTENTE SOCIAL I" | descargo=="ASISTENTE SOCIAL II" | descargo=="PSICOLOGO" | descargo=="PSICOLOGO (ADM)" | descargo=="PSICOLOGO I"
gen psicologo=plaza_administrativa==1
gen psicologo_n=1==(psicologo==1 & sitlab == "N")
gen psicologo_c=1==psicologo_n==0

*Coordinador administrativo de IE
tokenize `""ESPECIALISTA ADMINISTRATIVO" "CONTADOR" "ESPECIALISTA ADMINISTRATIVO I" "ESPECIALISTA ADMINISTRATIVO II" "ESPECIALISTA ADMINISTRATIVO III" "TECNICO EN FINANZAS" "JEFE DE AREA ADMINISTRATIVA" "TECNICO EN CONTABILIDAD" "TECNICO EN CONTABILIDAD I" "TECNICO ADMINISTRATIVO II" "TECNICO ADMINISTRATIVO III" "TECNICO ADMINISTRATIVO I" "TECNICO ADMINISTRATIVO" "TESORERO" "TECNICO EN PERSONAL II" "DIRECTOR DE SISTEMA ADMINISTRATIVO II" "SUB DIRECTOR DE SISTEMA ADMINISTRATIVO" "SUB DIRECTOR DE AREA ADMINISTRATIVA" "ESPECIALISTA EN FINANZAS" "TECNICO EN CAPACITACION Y DIFUSION" "TESORERO I" "TECNICO EN PERSONAL I" "TECNICO EN ABASTECIMIENTO" "TECNICO EN ABASTECIMIENTO II" "CONTADOR II" "CAJERO" "COORDINADOR ADMINISTRATIVO Y DE RECURSOS EDUCATIVOS PARA ZONAS RURALES" "COORDINADOR ADMINISTRATIVO Y DE RECURSOS EDUCATIVOS PARA ZONAS URBANAS" "RELACIONISTA PUBLICO I""'
foreach x of numlist 1(1)29 {	
	replace plaza_administrativa = 2 if descargo == "``x''" & mi(plaza_administrativa)	
}
 
gen coord_adm_ie=plaza_administrativa==2
gen coord_adm_ie_n=1==(coord_adm_ie==1 & sitlab == "N")
gen coord_adm_ie_c=coord_adm_ie_n==0

*Secretario(a)
tokenize `""PERSONAL DE SECRETARIA" "SECRETARIA" "SECRETARIA I" "SECRETARIA II" "SECRETARIA III" "SECRETARIA IV""'
foreach x of numlist 1(1)6 {	
	replace plaza_administrativa = 3 if descargo == "``x''" & mi(plaza_administrativa)	
}
gen secretario=plaza_administrativa==3
gen secretario_n=1==(secretario==1 & sitlab == "N")
gen secretario_c=secretario_n==0

*Auxiliar de biblioteca
tokenize `""AUXILIAR DE BIBLIOTECA" "AUXILIAR DE BIBLIOTECA I" "AUXILIAR DE BIBLIOTECA II" "BIBLIOTECARIO" "BIBLIOTECARIO I" "TECNICO EN BIBLIOTECA" "TECNICO EN BIBLIOTECA I" "TECNICO EN BIBLIOTECA II" "TECNICO EN BIBLIOTECA III" "TECNICO EN IMPRESIONES" "TECNICO EN IMPRESIONES I" "AUXILIAR DE VIDEOTECA""'
foreach x of numlist 1(1)12 {
	replace plaza_administrativa = 4 if descargo == "``x''" & mi(plaza_administrativa)
}
gen aux_biblioteca=plaza_administrativa==4
gen aux_biblioteca_n=1==(aux_biblioteca==1 & sitlab == "N") 
gen aux_biblioteca_c=aux_biblioteca_n==0

*Auxiliar de laboratorio
tokenize `""TECNICO EN LABORATORIO" "TECNICO EN LABORATORIO I" "TECNICO EN LABORATORIO II" "TECNICO EN LABORATORIO III" "AUXILIAR DE LABORATORIO" "AUXILIAR DE LABORATORIO I" "AUXILIAR DE LABORATORIO II""'
foreach x of numlist 1(1)7 {
	replace plaza_administrativa = 5 if descargo == "``x''" & mi(plaza_administrativa)
}
gen aux_laboratorio=plaza_administrativa==5
gen aux_laboratorio_n=1==(aux_laboratorio==1 & sitlab == "N")
gen aux_laboratorio_c=aux_laboratorio_n==0

*Auxiliar de soporte informático
tokenize `""COORDINADOR DE INNOVACION Y SOPORTE TECNOLOGICO" "OPERADOR DE EQUIPO DE IMPRENTA" "PROGRAMADOR DE SISTEMAS PAD" "ANALISTA DE SISTEMAS PAD" "OPERADOR PAD" "OPERADOR PAD I" "OPERADOR PAD II" "OPERADOR PAD III""'
foreach x of numlist 1(1)8 {
	replace plaza_administrativa = 6 if descargo == "``x''" & mi(plaza_administrativa)
} 
gen aux_sistemas=plaza_administrativa==6
gen aux_sistemas_n=1==(aux_sistemas==1 & sitlab == "N")
gen aux_sistemas_c=aux_sistemas_n==0

*Oficinista
tokenize `""AUXILIAR DE CONTABILIDAD" "AUXILIAR DE CONTABILIDAD II" "AUXILIAR DE OFICINA" "AUXILIAR DE OFICINA II" "AUXILIAR DE PUBLICACIONES" "AUXILIAR DE PUBLICACIONES II" "AUXILIAR DE SECRETARIA" "AUXILIAR DE SISTEMA ADMINISTRATIVO" "AUXILIAR DE SISTEMA ADMINISTRATIVO I" "OFICINISTA" "OFICINISTA I" "OFICINISTA II" "OFICINISTA III" "ASISTENTE DE SISTEMA ADMINISTRATIVO I""'
foreach x of numlist 1(1)14 {
	replace plaza_administrativa = 7 if descargo == "``x''" & mi(plaza_administrativa)
}
gen oficinista=plaza_administrativa==7
gen oficinista_n=1==(oficinista==1 & sitlab == "N")
gen oficinista_c=oficinista_n==0 // Incluye CAS

*Trabajador de limpieza y mantenimiento
tokenize `""TRABAJADOR DE SERVICIO" "TRABAJADOR DE SERVICIO I" "TRABAJADOR DE SERVICIO II" "TRABAJADOR DE SERVICIO III" "ARTESANO" "ARTESANO III" "SUPERVISOR DE CONSERVACION Y SERVICIOS" "SUPERVISOR DE CONSERVACION Y SERVICIOS I" "SUPERVISOR DE CONSERVACION Y SERVICIOS II" "PERSONAL DE MANTENIMIENTO" "ARTESANO I" "ARTESANO II" "ELECTRICISTA""'
foreach x of numlist 1(1)13 {
	replace plaza_administrativa = 8 if descargo == "``x''" & mi(plaza_administrativa)
} 
gen pers_limp_mant=plaza_administrativa==8
gen pers_limp_mant_n=1==(pers_limp_mant==1 & sitlab == "N")
gen pers_limp_mant_c=pers_limp_mant_n==0 //Incluye CAS

*Personal de vigilancia
replace plaza_administrativa = 9 if descargo=="PERSONAL DE VIGILANCIA" | descargo=="TECNICO EN SEGURIDAD" | descargo=="TECNICO EN SEGURIDAD I" | descargo=="TECNICO EN SEGURIDAD II" | descargo=="CHOFER" | descargo=="CHOFER I" | descargo=="CHOFER II" | descargo=="CHOFER III" | descargo=="PERSONAL DE SEGURIDAD RESIDENCIAS"
gen pers_vigilancia = plaza_administrativa==9
gen pers_vigilancia_n=1==(pers_vigilancia==1 & sitlab == "N")
gen pers_vigilancia_c=pers_vigilancia_n==0 //Incluye CAS

*Definir nombres en un label
label define plaza_administrativa 1 "Psicologo" 2 "Coordinador Administrativo IE" 3 "Secretaria" 4 "Auxiliar de biblioteca" 5 "Auxilar de laboratorio" 5 "Auxiliar de laboratorio" 6 "Auxiliar en soporte informático" 7 "Oficinista" 8 "Trabajador de limpieza y mantenimiento" 9 "Personal de vigilancia"

gen new_sitlab = upper(sitlab)== "N"
label define new_sitlab 1 "Nombrado" 0 "Contratado"
label val new_sitlab new_sitlab

levelsof plaza_administrativa, local(equivalencias)
tokenize `""Psicologo" "Coordinador Administrativo IE" "Secretario" "Auxiliar de biblioteca" "Auxiliar de laboratorio" "Auxiliar en soporte informático" "Oficinista" "Trabajador de limpieza" "Personal de vigilancia""'
foreach x of local equivalencias {
    di "-------------------- ``x'' --------------------"
    tab descargo new_sitlab if plaza_administrativa == `x'
	tab2xl descargo new_sitlab using "Documentos\Equivalencias.xlsx" if plaza_administrativa == `x' , col(1) row(1) sheet("``x''", replace)
}
 
tab2xl descargo using "Documentos\Equivalencias.xlsx" if mi(plaza_administrativa) & desctipotrab=="ADMINISTRATIVO" , col(1) row(1) sheet("Sin clasificacion", replace)

