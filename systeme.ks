// fichier systeme.ks

global coiffe is list().
global antenne is list().
global panneau is list().
global jambe is list().
global science is list().

for part in ship:parts {
    if part:tag = "coiffe" {coiffe:add(part).}
    if part:tag = "antenne" {antenne:add(part).}
    if part:tag = "panneau" {panneau:add(part).}
    if part:tag = "jambe" {jambe:add(part).}
    if part:tag = "science" {science:add(part).}
}

global function deployerCoiffe{
    for part in coiffe {
        part:getModule("ModuleProceduralFairing"):doEvent("déployer").
    }
    print ("Coiffe déployée.").
}

global function deployerAntenne{
    for part in antenne {
        part:getModule("ModuleDeployableAntenna"):doEvent("déployer antenne").
    }
    print ("Antenne(s) déployée(s)").
}

global function deployerPanneau{
    for part in panneau {
        part:getModule("ModuleDeployableSolarPanel"):doEvent("déployer panneau solaire").
    }
    print ("Panneau(x) solaire(s) déployé(s)").
}

global function deployerJambe {
  for part in jambe {
    part:getModule("ModuleWheelDeployment"):doevent("étendre").
  }
  print("Jambes d'atterrissage déployées.").
}

global function deployerScience {
  for part in science {
    local mod is part:getModule("ModuleScienceExperiment").
    mod:deploy.
    wait until mod:hasData.
    mod:transmit.
  }
  print("Expériences scientifiques déployées.").
}

global function limitePuissance {
  parameter pourcentage.
  list ENGINES in listeMoteur.
  for moteur in listeMoteur {
    set moteur:thrustLimit to pourcentage.
  }
}