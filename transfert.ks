// fichier transfert.ks

function transfert{
  parameter corpsCible.
  set target to corpsCible.

  local angleCible is 180 - calculerAngleCible(target).
  lock anglePhase to calculerAnglePhase(target).
  
  until abs(angleCible - anglePhase) < 10 {
    set warp to 3.
  }
  set warp to 0.
  wait until kuniverse:timewarp:rate = 1.

  local deltaAngle is abs(angleCible - anglePhase).
  local deltaTemps is deltaAngle * ship:orbit:period / 360.

  local deltaV is transfertHohmann(ship:altitude, corpsCible:orbit:apoapsis - corpsCible:radius).
  add node(time:seconds + deltaTemps, 0, 0, deltaV).
  
  executerManoeuvre(0).

  if orbit:nextpatch:periapsis < 2000 {
    lock steering to retrograde.
    limitePuissance(0.5).
    wait 3.
    until orbit:nextpatch:periapsis > 7000 {
      lock throttle to 0.1.
    }
  }
  lock throttle to 0.
  limitePuissance(100).
  wait 2.

  warpto(time:seconds + ETA:transition + 120).
  wait until kuniverse:timewarp:rate = 1.
}

function calculerAngleCible {
  parameter corpsCible.
  local futurPe is ship:apoapsis.
  local semiMajorAxis is (body:radius + futurPe + body:radius + corpsCible:orbit:apoapsis) / 2.
  local demiPeriode is constant:pi * sqrt(semiMajorAxis^3 / body:mu).
  local periodeCorpsCible is corpsCible:orbit:period.
  return demiPeriode * 360 / periodeCorpsCible.  
}

function calculerAnglePhase {
  parameter corpsCible.
  
  local angleVaisseauVernal is
    ship:orbit:lan + ship:orbit:argumentofperiapsis + ship:orbit:trueanomaly.
  local angleVaisseau is angleVaisseauVernal - 360*floor(angleVaisseauVernal / 360).

  local angleCibleVernal is
    corpsCible:orbit:lan + corpsCible:orbit:argumentofperiapsis + corpsCible:orbit:trueanomaly.
  local angleCible is angleCibleVernal - 360 * floor(angleCibleVernal / 360).

  local diffAngle is angleCible - angleVaisseau.
  return diffAngle - 360 * floor(diffAngle/360).
}
