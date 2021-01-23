// fichier manoeuvresOrbitales.ks

global function calculerVitesse {
    parameter peri, apo, altitudeVaisseau.
    
    local rayon is body:radius.
    local RV is rayon + altitudeVaisseau. // altitude du vaisseau depuis centre de masse
    local RP is rayon + peri. // periapsis du vaisseau depuis centre de masse
    local RA is rayon + apo. // apoapsis du vaisseau depuis centre de masse
    local DGA is (RA + RP) / 2. // demi grand axe

    return sqrt(body:mu * (2/RV - 1/DGA)). // SQuare RooT
}


global function transfertHohmann {
    parameter altitudeVaisseau, altitudeCible.
    local vitesseInitiale is 0.
    local vitesseFinale is 0.
    local deltaV is 0.

    set vitesseInitiale to calculerVitesse(ship:orbit:periapsis, ship:orbit:apoapsis, altitudeVaisseau).

    if altitudeVaisseau < altitudeCible {
        set vitesseFinale to calculerVitesse(altitudeVaisseau, altitudeCible, altitudeVaisseau).
    }
    else {
        set vitesseFinale to calculerVitesse(altitudeCible, altitudeVaisseau, altitudeVaisseau).
    }

    set deltaV to vitesseFinale - vitesseInitiale.

    print ("------ Vitesses de la manoeuvre ------").
    print ("Vi = ") + round(vitesseInitiale, 2) + (" m/s.").
    print ("Vf = ") + round(vitesseFinale, 2) + (" m/s.").
    print ("Delta V = ") + round(deltaV, 2) + (" m/s.").
    print ("------").

    return deltaV.
}


global function circularisation {
    parameter ApPe.
    local deltaV is 0.
    local noeudCirc is node(0, 0, 0, 0). // node (TU au moment où on effectue la manoeuvre, radial, normal, prograde)

    if ApPe = "AP" {
        set deltaV to transfertHohmann(ship:orbit:apoapsis, ship:orbit:apoapsis).
        set noeudCirc to node(time:seconds + ETA:apoapsis, 0,0, deltaV).
    }
    else {
        set deltaV to transfertHohmann(ship:orbit:periapsis, ship:orbit:periapsis).
        set noeudCirc to node(time:seconds + ETA:periapsis, 0,0, deltaV).
    }

    print ("Calcul de la circularisation effectué.").
    print ("------").

    add noeudCirc.
}


global function executerManoeuvre {
    parameter DeltaBurnTime.
    local noeud is nextNode.
    lock steering to noeud:burnVector.

    local max_acc is ship:maxthrust/ship:mass.
    local burn_duration is noeud:deltav:mag/max_acc.
    set burn_duration to burn_duration + DeltaBurnTime * burn_duration.

    warpTo(time:seconds + noeud:eta - (burn_duration/2 + 20)).

    wait until noeud:eta <= (burn_duration/2).

    local tset is 0.
    lock throttle to tset.

    local done is False.
    local dv0 is noeud:deltav.

    until done
    {
        set max_acc to ship:maxthrust/ship:mass.
        set tset to min(noeud:deltav:mag/max_acc, 1).

        if vdot(dv0, noeud:deltav) < 0 {lock throttle to 0. break.}

        if noeud:deltav:mag < 0.1 {
        wait until vdot(dv0, noeud:deltav) < 0.5.
        lock throttle to 0.
        set done to True.
        }
    }
    unlock steering.
    unlock throttle.
    wait 1.

    remove noeud.
    lock steering to prograde.
}