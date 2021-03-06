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
    echo "*** Erreur: $msg" >&2
    echo "" >&2

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
    if [ $# -eq 1 ]; then
        if [[ $1 == '--detruire' ]]; then
            shift
            \rm -f $le_depot
            detruire=0
        fi
    fi
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
#./gv.sh ajouter --qte=29 Beaujolais 2017 Foillard 22.00

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
    #verifier_arguments_en_trop "$@"
    if [[ ($@ == "--court") || ($@ == "--format=court")]]; then
        awk -F":" '{printf "%s [%s$]: %s %s, %s\n", $1, $7, $4, $5, $6}' $le_depot
    elif [[ ($@ == "--long") || ($@ == "--format=long") || ($@ == '')]]; then
        awk -F":" '{printf "%s [%-5s  -  %s$]: %s %s, %s (%s) => %s {%s}\n", $1, $3, $7, $4, $5, $6, $2, $8, $9}' $le_depot
    else
        echo ''
    fi
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
    quantite=1
    type=rouge
    nbArguments=0
    
    # Valider les arguments
    if [[ ($@ == *" --qte="*) || ($@ == "--qte="*)]]; then
        quantite=$(echo "$@" | grep -oP '(?<=--qte=)[0-9][0-9]?')
        nbArguments=$((nbArguments + 1))
    fi
    if [[ ($@ == *" --type="*) || ($@ == "--type="*)]]; then
        type=$(echo "$@" | grep -oP '(?<=--type=)[^ ]+')
        nbArguments=$((nbArguments + 1))
    fi
    # Enlever les arguments pour passer aux valeurs
    if [[ ($nbArguments == 1) ]]; then
        shift
    fi
    if [[ ($nbArguments == 2) ]]; then
        shift 2
    fi
    
    #Avoir le numéro du prochain enregistrement a ajouter
    numEntree=$(awk -F":" '{w=$1} END{print w}' $le_depot)
    numEntree=$((numEntree + 1))
    #Prendre toutes les valeurs
    if [ "$#" -ne 4 ]; then  
        erreur "Nombre incorrect d'arguments"
    fi
    apellation=$1
    if echo $2 | grep -E -q "^[1-2][0-9]{3}\$"; then
        millesime=$2  
    else
        erreur "Nombre invalide pour le millesime"
    fi
    nom=$3
    if echo $4 | grep -E -q "^[0-9]+.[0-9]+\$"; then
        prix=$4  
    else
        erreur "Nombre invalide pour le prix"
    fi
    shift 4
    verifier_arguments_en_trop "$@"
    generer_enregistrement_vin $numEntree $type $apellation $millesime $nom $prix >> $le_depot
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
    numEntree=$1
    note=$2
    if [[ ($note > 5) || ($note <1) ]]; then
        erreur "Nombre invalide"
    fi
    commentaire=$3
    shift 3
    verifier_arguments_en_trop "$@"
    ligneTrouve=$(grep -E "^$numEntree.*" $le_depot)
    ligneModifiee=$(grep -E "^$numEntree.*" $le_depot | sed --expression="s/::/:$note:$commentaire/g")
    sed -i -e "s|$ligneTrouve|$ligneModifiee|g" $le_depot
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
    argument=''
    motif=''
    #Vérifier si un argument, un motif ou les deux sont recus
    if [ "$#" -ne 0 ]; then
        if [[ ($1 != "--bus") && ($1 != "--non-bus") && ($1 != "--tous") && ($1 != "")]]; then
            motif=$1
            shift
        elif [ "$#" -eq 2 ]; then
            argument=$1
            motif=$2
            shift 2
        else
            argument=$1
            shift
        fi
    fi
    verifier_arguments_en_trop "$@"
    if [ -s $le_depot ]; then
        #Traiter tous les cas selon ce qui a ete recu
        if [[ ($argument == "--bus") ]]; then
            grep -E "^(([^:]*:){8}).+" $le_depot | grep -E "$motif"
        elif [[ ($argument == "--non-bus") ]]; then
            grep -E "^([^:]*:){7}:"  $le_depot | grep -E "$motif"
        elif [[ ($argument == "--tous") ||  ($argument == "") ]]; then
            grep "^\w.*" $le_depot | grep -E "$motif"
        else
            ''
        fi
    fi
    
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
    if [ $# -le 2 ]; then
        sortVar="sort -t: -k1"
        while [ $# -ne 0 ]
            do
            case "$1" in
            "--appellation")
                sortVar="sort -t: -k4"
            ;;
            "--date-achat")
                sortVar="sort -t: -k2"
            ;;
            "--millesime")
                sortVar="sort -t: -nk5"
            ;;
            "--nom")
                sortVar="sort -t: -k6"
            ;;
            "--numero" | "")
                sortVar="sort -t: -nk1"
            ;;
            "--prix")
                sortVar="sort -t: -nk7"
            ;;
            "--CLE")
                sortVar="sort -t: -k1"
            ;;
            "--reverse")
                sortVar="$sortVar -r"
            ;;
            *)
                verifier_arguments_en_trop "$@"
            ;;
            esac
            shift
        done
        verifier_arguments_en_trop "$@"
        $sortVar $le_depot
    else
        shift 2
        verifier_arguments_en_trop "$@"
    fi
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
    numVin=$1
    shift
    verifier_arguments_en_trop "$@"
    ligneTrouve=$(grep -E "^$numVin.*(::)\$" $le_depot)
    if [[ $ligneTrouve != '' ]]; then
        echo $ligneTrouve
        sed -i -e "s|$ligneTrouve||g" $le_depot
        #cat $le_depot | grep . > $le_depot
        #sed -i -E "$numVin"/d" $le_depot
    fi
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
    if [[ $# != 0 ]]; then
        if [[ $1 == "--depot="* ]]; then
            type=$(echo "$@" | grep -oP '(?<=--depot=)[^ ]+')
            le_depot=$type
            shift
        fi
        if  [[ ($1 == '-') ]];then
            le_depot=$type
            shift
        fi
    fi
    
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

