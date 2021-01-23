// fichier suicidBurn.ks

function atterrissage {
    parameter corpsCible.
    clearScreen.

    lock altitudeAGL to ship:altitude - ship:geoposition:terrainHeight.

    set navMode to "SURFACE".
    lock steering to srfRetrograde.
    wait 1.

    wait until altitudeAGL < 2000.

    set tset to 1.
    lock throttle to tset.

    set done to False.
    lock vitesseSurface to ship:velocity:surface:mag.

    until done
    {
        set tset to min(vitesseSurface/100, 1).

        if vitesseSurface < 5 {lock throttle to 0. set done to true.}
    }

    deployerJambe().

    limitePuissance(10).

    local graviteCorps is corpsCible:mu / ((corpsCible:radius)^2).

    // En : TWR = Thrust To Weight ratio
    // Fr : RPP = Rapport Poussée Poids
    // Poids = masse * gravité
    local RPP is ship:availablethrust / (ship:mass * graviteCorps).

    local altitudeInitiale is altitudeAGL.
    local altitudeAllumage is altitudeInitiale / RPP.

    print("Altitude d'allumage du moteur : ").
    print(round(altitudeAllumage,2)) + (" m.").


    lock steering to srfRetrograde.

    wait until altitudeAGL <= altitudeAllumage.
    lock throttle to 1.

    wait until ship:verticalspeed > -5.
    lock steering to UP.

    set altitudeActuelle to altitudeAGL.

    until ship:verticalspeed > -0.2 {
        lock throttle to min(altitudeAGL/altitudeActuelle, 0.1).
    }

    lock throttle to 0.
    unlock throttle. unlock steering.
}