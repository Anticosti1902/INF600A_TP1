#!/bin/bash -

##########################################################################
# Script pour programme de gestion d'une cave a vins.
##########################################################################

set -o nounset  # Pour signaler une erreur si une variable non definie est utilisee.
set -o errexit  # Pour signaler une erreur si un exit status non nul est produit


##########################################################################
# Constantes et fonctions liees a la representation des
# enregistrements du fichier des vins.
#
# Information mise dans un fichier a part pour respecter le plus
# possible le principe de <<dissimulation de l'information>>
# (information hiding).
##########################################################################

source ./bd-vins.sh


##########################################################################
# Variable *globale* identifiant le depot.
##########################################################################

# Pourra etre redefinie par l'option appropriee:
#  * Toutes les commandes: <<--depot=autre_nom_de_fichier>>
#  * lister, trier, selectionner: <<->>

le_depot="$DEPOT_DEFAUT"


##########################################################################
# Fonctions pour debogage et traitement des erreurs.
##########################################################################

# Pour generer des traces de debogage avec la function debug, il
# suffit de modifier pour DEBUG=1
DEBUG=0
#DEBUG=1

#===========
# Affiche une trace de deboggage.
#
# Arguments: [chaine...]
#===========
function debug {
    [[ $DEBUG == 0 ]] && return

    echo -n "[debug] "
    for arg in "$@"; do
        echo -n "'$arg' "
    done
    echo ""
}

#===========
# Affiche un message d'erreur (sur stderr).
#
# Arguments: msg
#===========
function erreur {
    local msg="$1"

    # A COMPLETER: Les erreurs doivent etre emises stderr...
    # mais ce n'est pas le cas pour l'instant!
    echo "*** Erreur: $msg"
    echo ""

    # On emet le message d'aide si la commande fournie est invalide.
    # Par contre, ce message -- contrairement au precedent -- doit etre emis sur stdout.
    [[ $msg =~ Commande\ inconnue ]] && aide
    
    exit 1
}


##########################################################################
# Fonction d'aide: fournie, pour uniformite.
#
# Arguments: Aucun
#
# Emet l'information sur stdout
##########################################################################
function aide {
    cat <<EOF
NOM
  $0 -- Script pour gestion d'une cave a vins

SYNOPSIS
  $0 [--depot=fich|-] commande [options-commande] [argument...]

COMMANDES
  aide          - Emet la liste des commandes
  ajouter       - Ajoute un vin
  init          - Cree une nouvelle base de donnees
                  (dans './$DEPOT_DEFAUT' si --depot n'est pas specifie)
  lister        - Liste les vins selon differents formats
  noter         - Attribue une note et un commentaire a un vin 
                  (qui n'a pas encore ete note)
  selectionner  - Selectionne les vins matchant divers motifs/criteres
  supprimer     - Supprime un vin (qui n'a pas encore ete note)
  trier         - Trie selon divers criteres
EOF
}

##########################################################################
# Fonctions pour manipulation du depot.
#
# Fournies pour simplifier le devoir et assurer au depart un
# fonctionnement minimal du logiciel.
##########################################################################

#===========
# Verifie que le depot indique existe, sinon signale une erreur.
#
# Arguments: depot
#===========
function verifier_depot_existe {
    local depot="$1"
    
    if [[ $depot != "-" ]]; then
        [[ ! -f $depot ]]  && erreur "Le fichier '$depot' n'existe pas!"
    fi
    
    return 0
}


function verifier_arguments_en_trop {
    [[ $# != 0 ]] && erreur "Argument(s) en trop: '$@'"
    return 0
}

#===========
# Commande init
#
# Arguments:  [--detruire]
#
# Erreurs:
#  - Le depot existe deja et l'option --detruire n'a pas ete indiquee
#===========
function init {
    local detruire=0
    # A COMPLETER: traitement de la switch --detruire!

    if [[ -f $le_depot ]]; then
        # Depot existe deja.
        # On le detruit quand --detruire est specifie.
        [[ $detruire != 1 ]] && erreur "Le fichier '$le_depot' existe. Si vous voulez le detruire, utilisez 'init --detruire'."
        \rm -f $le_depot
    fi

    # On 'cree' le fichier vide.
    touch $le_depot

    verifier_arguments_en_trop "$@"
}

##########################################################################
#
# Les fonctions pour les diverses commandes de l'application.
#
# A COMPLETER!
#
##########################################################################


#===========
# Commande lister
#
# Arguments: [--court|--long|--format=un_format]
#
# Valeur par defaut si option omise:
#   --long
#
# Erreurs:
# - depot inexistant
#===========
function lister {
    verifier_arguments_en_trop "$@"
}


#===========
# Commande ajouter
#
# Arguments: [--qte=99] [--type=chaine] appellation millesime nom prix
#
# Valeurs par defaut si options omises:
#   --qte=1
#   --type=rouge
#
# Erreurs:
# - depot inexistant ou invalide (- ne peut pas etre utilise)
# - nombre incorrect d'arguments
# - nombre invalide pour la quantite
# - nombre invalide pour le millesime
# - nombre invalide pour le prix (99.99)
#===========

function ajouter {
    verifier_arguments_en_trop "$@"
}

#===========
# Commande noter
#
# Arguments: numero_vin note commentaire
#
# Erreurs:
# - depot inexistant ou invalide (- ne peut pas etre utilise)
# - nombre incorrect d'arguments
# - vin avec le numero n'existe pas
# - vin deja note
# - nombre invalide pour la note (0 a 5)
#===========
function noter {
    verifier_arguments_en_trop "$@"
}


#===========
# Commande selectionner
#
# Arguments: [--bus|--non-bus|--tous] [motif]
# 
# Valeur par defaut si options et motif omiss:
#   --tous
#
# Erreurs:
# - depot inexistant
#===========
function selectionner {
    verifier_arguments_en_trop "$@"
}


#===========
# Commande trier
#
# Arguments: depot [--appellation|--date-achat|--millesime|--nom|--numero|--prix|--cle=CLE] [--reverse]
# 
# Valeur par defaut si options omises:
#   --numero
#
# Erreurs:
# - depot inexistant
# - nombre incorrect d'arguments
#===========
function trier {
    verifier_arguments_en_trop "$@"
}

#===========
# Commande supprimer
#
# Arguments: num_vin
# 
# Erreurs:
# - depot inexistant ou invalide (- ne peut pas etre utilise)
# - nombre incorrect d'arguments
# - num_vin inexistant
# - num_vin deja note
#===========
function supprimer {
    verifier_arguments_en_trop "$@"
}

##########################################################################
# Le programme principal
#
# La strategie utilisee pour uniformiser le trairement des commandes
# est la suivante :
#
# - Une commande est mise en oeuvre par une fonction du meme nom que
#   la commande.
# 
# - Avant l'appel de la commande/fonction, l'option de specification
#   du depot est analysee (et, le cas echeant, elle est supprime de la
#   liste des arguments).
#
# - La fonction appelee devra tout d'abord traiter les
#   options. Ensuite, elle devra verifier qu'un nombre approprie
#   d'arguments est specifie -- y compris signaler une erreur si des
#   arguments superflus ont ete indiques. Enfin, la fonction effectue
#   le traitement requis.
#
##########################################################################

function main {
    # On definit le depot a utiliser et on verifie qu'il existe.
    # A COMPLETER: il faut verifier si le flag <<--depot=...>> ou la pseudo-option
    # d'utilisation du flux stdin a ete specifie.
    # Si oui, il faut modifier le_depot (var. globale) en consequence!
    le_depot="$DEPOT_DEFAUT"
    
    debug "On utilise le depot suivant:", $le_depot

    # On analyse la commande (= dispatcher).
    local commande="aide"
    if [[ $# != 0 ]]; then
        commande="$1"; shift
    fi
    case "$commande" in
        aide)
            aide;;

        init)
            init "$@";;
        
        ajouter|lister|supprimer|noter|selectionner|trier)
            verifier_depot_existe "$le_depot"
            $commande "$@";;
        
        *) 
            erreur "Commande inconnue: '$commande'";;
    esac
}

##########################################################################

main "$@"

exit 0
