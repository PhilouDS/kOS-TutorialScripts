// fichier lancement.ks

global function decollage {
    parameter inclinaison.

    sas off.
    rcs off.
    lock throttle to 1.

    lock steering to heading(90, 90).
    // heading(direction, pitch)
    // direction E = 90, N = 0, S = 180, O = 270
    // pitch = orientation par rapport à l'horizontal - 90 = pointe vers le haut

    compteRebours(10).

    stage.
    print ("Allumage des boosters !").
    wait 1.

    stage.
    print("Décollage !").

    wait until ship:altitude > 150.
    lock steering to heading(90 - inclinaison, 90).
    print("Correction de l'inclinaison en cours.").
}

function compteRebours{
    parameter decompteSecondes.
    print("Compte à rebours enclenché.").
    wait 1.
    from {local monCompteur is decompteSecondes.}
    until monCompteur = 0
    step {set monCompteur to monCompteur - 1.}
    do {
        print ("...") + monCompteur + ("...").
        wait 1.
    }
}

// pour faire une boucle 
// from : définir une variable locale qui correspond au compteur
// until : définir la condition de sortie de boucle
// step : définir le changement du compteur à chaque passage de la boucle
// do : écrire concrètement ce qu'il se passe à chaque étape de la boucle


global function gravityTurn {
    parameter altitudeVoulue, inclinaison, angle.
    local directionDepart is heading(90 - inclinaison, angle).
    lock steering to directionDepart.

    wait until vAng(facing:vector, directionDepart:vector) < 1.
    wait until vAng(srfPrograde:vector, facing:vector) < 1.

    local maxQ is 0.
    local maxAltitudeQ is 0.

    until ship:altitude > 65000 {
        lock steering to heading(90 - inclinaison, 90 - vAng(up:vector, srfPrograde:vector)).

        if ship:apoapsis >= 0.95 * altitudeVoulue and ship:apoapsis < altitudeVoulue {lock throttle to 0.25.}
        if ship:apoapsis >= altitudeVoulue {lock throttle to 0.}

        if ship:q > maxQ {
            set maxQ to ship:q.
            set maxAltitudeQ to ship:altitude.
        }
        wait 0.1.    
    }
    print (" ").
    print ("maxQ / maxQaltitude :") at (0,17).
    print round(constant:ATMtokPa * maxQ, 2) + ("kPa / ") + round(maxAltitudeQ, 0) + (" m.") at (0,18).
}