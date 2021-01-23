// fichier boot.ks

lancerProgramme().


global function lancerProgramme {
    core:part:getModule("kOSProcessor"):doEvent("Open Terminal").
    chargerFichier("1:/", main.ks).
}


global function chargerFichier {
    parameter destination, nomFichier.
    copypath("0:/" + nomFichier, destination + nomFichier).
    runPath(destination + nomFichier).
}

global function fermerProgramme{
    clearScreen.
    print("Fin des instructions.").
    print("Fermeture du programme dans 3 sec.").
    wait 3.
    set ship:control:pilotMainThrottle to 0.
    core:part:getModule("kOSProcessor"):doEvent("Close Terminal").
    shutdown.
}