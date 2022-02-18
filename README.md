# Brecha-no-docente
Este repositorio analiza la brecha de personal no docente (administrativo) en los SSEE publicos del Peru para los locales educativos de la modalidad de Educación Básica Regular (EBR). Los personales que se analizan los siguientes cargos:

1) Coordinador/a Administrativo de IIEE
2)  Oficinista
3) Secretario/a
4) Personal de Limpieza y Mantenimiento
5) Personal de Vigilancia

Para la brecha de personal de limpieza y mantenimiento se evaluan 2 escenarios de brecha con ordenamiento de plazas excedentes y un escenario de focalización

## Estructura de las carpetas

```markdown
├── Documentos
  ├── 'RVM 126-2020-MINEDU.pdf'               -> Establece los criterios de asignacion
  ├── 'Equivalencias.xlsx'                    -> Equivalencia de los antiguos cargos con los actuales de la RVM 126-2020-Minedu por situación laboral

├── Scripts
  ├── 'Diagnostico de equivalencias.do'       -> Construye el excel 'Equivalencias.xlsx'
  ├── 'Construccion de la base.do'            -> Construye la base 'Base administrativos.dta'
  ├── 'Prediccion de personal.do'             -> Regresiones para determinar la asignacion del personal de limpieza
  ├── 'Calculo de la brecha.do'               -> Construye 'Brecha con costo.dta' y 'Brecha personal administrativo.xlsx'
  ├── 'Focalizacion.do'                       -> Construye la pestaña 'Focalizacion Limpieza' en 'Brecha personal administrativo.xlsx'
  ├── 'Brecha de personal de limpieza.ipynb'  -> Construye 'Personal de limpieza.xlsx'

├── Resultados
    ├── 'Base administrativos.dta'            -> Base a nivel de local educativo con el personal no docente actual
    ├── 'Brecha con costo.dta'                -> Base a nivel de local educativo con los costos de la brecha de personal no docente
    ├── 'Brecha personal administrativo.xlsx'  
        ├── Equivalencias                     -> Equivalencia de los antiguos cargos con los actuales de la RVM 126-2020-Minedu
        ├── Resultados ie                     -> Base a nivel de local educativo con el personal no docente actual
        ├── Sueldo base                       -> Listas de sueldos a propuestos por tipo de trabajador
        ├── Criterios de Costeo               -> Metodo para calcular el costo anual de cada trabajador
        ├── Resumen                           -> Resumen de la brecha por tipo de trabajador no docente
        ├── Personal de limpieza              -> Brecha con costo del personal de limpieza sin criterios de ordenamiento
        ├── Focalizacion Limpieza             -> Base a nivel de local educativo de la Focalización del personal de limpieza
        ├── Brecha-Racio                      -> Brecha de personal de limpieza con ordenamiento a nivel de región
    ├── 'Brecha no docente.xlsx'
        ├── UGEL sin racio                    -> Brecha a nivel de UGEL sin criterios de ordenamiento
        ├── UGEL con racio                    -> Brecha a nivel de UGEL con criterios de ordenamiento
```

## Pasos para replicar

Correr los siguientes Scripts y do files en el siguiente orden para replicar el proyecto:

1) 'Diagnostico de equivalencias.do' (Opcional)
2) 'Construccion de la base.do'
3) 'Prediccion de personal.do' (Opcional)
4) 'Calculo de la brecha.do'
5) 'Focalizacion.do'
6) 'Brechas de personal no docente.ipynb'
