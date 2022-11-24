# nehody_mapa

Map of accidents and traffic data in the Slovak republic between 2012 and 2022 *(Further in Slovak)*.

View at: https://kovy217.shinyapps.io/nehody_mapa/ 

---

# Analýza cestnej nehodovosti

## Cestné nehody	
Dáta o cestných nehodách sú generované zo štatistiky [Ministerstva vnútra](https://www.minv.sk/?kompletna-statistika) a sú k dispozícii pre časové obdobie od 1. 1. 2012 do 30. 9. 2022. Tzv. **topografické zostavy nehôd** sú Dopravnou políciou v danom období zverejnené pre cesty II. a vyššej triedy (s výnimkou rýchlostných ciest pre roky 2021 a 2022). Údaje sú zverejnené v podobe kódov položiek v zázname dopravnej nehody, ktoré sú vysvetlené podľa tzv. [číselníkov](https://www.minv.sk/lnisdn/statistika/20191003_195619.453_2019-09-MS/statistika/vysvetlivky.html).

Keďže pre jednotlivé nehody nie sú zverejnené ich GPS súradnice (iba informácie o kilometri danej cestnej komunikácie, na ktorom sa nehoda udiala), ich zemepisná poloha je vypočítavaná dodatočne, pomocou interpolácie, teda umiestnením nehodovej udalosti medzi dva najbližšie referenčné body na danej ceste (cestné uzly/dopravné značky). Účelom mapy nie je presné zobrazenie geografickej polohy dopravných nehôd. Údaje o cestných uzloch a dopravných značkách pochádzajú z databázy [Slovenskej správy ciest](https://www.cdb.sk/sk/statisticke-vystupy.alej) pod licenciou [Creative Commons Attribution](http://opendefinition.org/licenses/cc-by/). Pre cesty, ktorých číslo (napr. I/50) alebo kilometrovníkové staničenie (napr. I/66) v danom období menilo, je staničenie dopravných nehôd prepočítané. 

![222](https://user-images.githubusercontent.com/47066564/203774392-87039968-d1a7-41a1-83af-e74707f1bf8a.png)
