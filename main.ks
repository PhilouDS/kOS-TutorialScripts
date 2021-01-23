// fichier main.ks

chargerFichier("1:/", "systeme.ks").
chargerFichier("1:/", "lancement.ks").
chargerFichier("1:/", "manoeuvresOrbitales.ks").
chargerFichier("1:/", "transfert.ks").
chargerFichier("1:/", "suicidBurn.ks").

global inclinaisonCible is 6.67.
global apoapsisCible is 100000.

clearScreen.

when ship:altitude > 70000 then {
    deployerCoiffe().
    wait 1.
    deployerAntenne().
    deployerPanneau().
}

decollage(inclinaisonCible).

when maxThrust = 0 then {
    stage.
    preserve.
}

wait until ship:altitude > 350 and ship:velocity:surface:mag > 80.

gravityTurn(apoapsisCible, inclinaisonCible, 80).

lock steering to heading(90 - inclinaisonCible, 0).

wait until ship:altitude > 71000.
clearScreen.

circularisation("AP").
wait 1.

executerManoeuvre(0.55).
wait 2.

transfert(Minmus).

if ship:orbit:periapsis < 10000 {
    circularisation("PE").
    wait 1.
    executerManoeuvre(0).
}
else {
    add node(time:seconds + ETA:periapsis, 0, 0, transferHohmann(ship:orbit:periapsis, 10000)).
    wait 1.
    executerManoeuvre(0).
    wait 1.
    circularisation("PE").
}

wait 3.

add node(time:seconds + ETA:apoapsis, 0, 0, transferHohmann(orbit:apoapsis, -500)).
wait 1.

executerManoeuvre(0).

wait 1.

atterrissage(Minmus).

wait until ship:status = "LANDED".
wait 2.

deployerScience().

wait 10.

fermerProgramme().