# nehody_mapa

Map of accidents and traffic data in the Slovak republic between 2012 and 2022 *(Further in Slovak)*.

View at: https://kovy217.shinyapps.io/nehody_mapa/ 

---

# Analýza cestnej nehodovosti

## Cestné nehody	
Dáta o cestných nehodách sú generované zo štatistiky [Ministerstva vnútra](https://www.minv.sk/?kompletna-statistika) a sú k dispozícii pre časové obdobie od 1. 1. 2012 do 30. 9. 2022. Tzv. **topografické zostavy nehôd** sú Dopravnou políciou v danom období zverejnené pre cesty II. a vyššej triedy (s výnimkou rýchlostných ciest pre roky 2021 a 2022). Údaje sú zverejnené v podobe kódov položiek v zázname dopravnej nehody, ktoré sú vysvetlené podľa tzv. [číselníkov](https://www.minv.sk/lnisdn/statistika/20191003_195619.453_2019-09-MS/statistika/vysvetlivky.html).

Keďže pre jednotlivé nehody nie sú zverejnené ich GPS súradnice (iba informácie o kilometri danej cestnej komunikácie, na ktorom sa nehoda udiala), ich zemepisná poloha je vypočítavaná dodatočne, pomocou interpolácie, teda umiestnením nehodovej udalosti medzi dva najbližšie referenčné body na danej ceste (cestné uzly/dopravné značky). Účelom mapy nie je presné zobrazenie geografickej polohy dopravných nehôd. Údaje o cestných uzloch a dopravných značkách pochádzajú z databázy [Slovenskej správy ciest](https://www.cdb.sk/sk/statisticke-vystupy.alej) pod licenciou [Creative Commons Attribution](http://opendefinition.org/licenses/cc-by/). Pre cesty, ktorých číslo (napr. I/50) alebo kilometrovníkové staničenie (napr. I/66) v danom období menilo, je staničenie dopravných nehôd prepočítané. 

<img width="943" alt="Screenshot 2022-11-25 at 15 09 14" src="https://user-images.githubusercontent.com/47066564/204002379-1a7b4c79-c067-4da8-a412-dea6cb74862b.png">


## Nehodové úseky

Analýza definovala cestný úsek ako medzikrižovatkový úsek cestnej komunikácie medzi danou komunikáciou a inými cestami II. a vyššej triedy. Pre účely analýzy bola nehodovosť vypočítaná na úsekoch ciest I. a II. triedy, rovnako ako aj na úsekoch rýchlostných ciest, ktoré slúžia ako obchvaty obcí a miest (napr. R4 v Svidníku). Nehodovosť daného úseku je vypočítaná v absolútnych aj relatívnych číslach. Geografické dáta o úsekoch pochádzajú z [Celoštátneho sčítania dopravy](https://www.ssc.sk/sk/cinnosti/rozvoj-cestnej-siete/dopravne-inzinierstvo.ssc) 2015 od SSC pod licenciou [Creative Commons Attribution](http://opendefinition.org/licenses/cc-by/).

### Absolútna nehodovosť
Určená ako počet ťažkých nehôd na úseku za dané obdobie v pomere k dĺžke úseku vynásobenej počtom rokov v sledovanom období. 

### Relatívna nehodovosť
Určená pomocou tzv. critical accident rate , počtu ťažkých dopravných nehôd na danom úseku v pomere k dopravnej intenzite daného úseku.

V oboch prípadoch sú do úvahy brané aj nehody na danej ceste 500 metrov pred a po konci daného úseku pre prípad nepresností určovania ich polohy. Táto pridaná dĺžka je vzatá do úvahy pri výpočtoch oboch štatistík. Nehodové úseky sú zaradené do ich kategórie (vysoká, nadpriemerná, nízka nehodovosť...) podľa kumulatívneho percenta cestnej siete, ktoré pokrývajú.

<img width="895" alt="Screenshot 2022-11-25 at 15 10 00" src="https://user-images.githubusercontent.com/47066564/204002524-012e663e-aeaf-4dd0-bd03-c70f138b795a.png">
