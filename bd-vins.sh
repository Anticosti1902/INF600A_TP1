# Nom du fichier pour le depot par defaut.
readonly DEPOT_DEFAUT='.vins.txt'

# Separateur pour les champs d'un enregistrement specificant un vin.
readonly SEPARATEUR=':'
readonly SEP=$SEPARATEUR # Alias, pour alleger le code

#
# Fonction pour creer une ligne d'enregistrement pour un vin, dans le
# format requis pour la BD textuelle.
#
generer_enregistrement_vin () {
    local num_vin="$1"
    local type_vin="$2"
    local appellation="$3"
    local millesime="$4"
    local nom="$5"
    local prix="$6"
    
    local date_achat=$(date "+%d/%m/%y")

    echo "${num_vin}${SEP}$date_achat${SEP}${type_vin}${SEP}${appellation}${SEP}${millesime}${SEP}${nom}${SEP}${prix}${SEP}${SEP}"
}

#
# Constantes pour identifier les differents champs d'un enregistrement pour un vin.
# 
readonly _NUMERO_=1
readonly _DATE_ACHAT_=2
readonly _TYPE_=3
readonly _APPELLATION_=4
readonly _MILLESIME_=5
readonly _NOM_=6
readonly _PRIX_=7
readonly _NOTE_=8
readonly _COMMENTAIRE_=9

#
# Fonctions specifiques pour obtenir les divers champs d'un enregistrement.
#
numero_vin() {
    echo "$1" | cut -d${SEP} -f${_NUMERO_}
}

date_achat_vin() {
    echo "$1" | cut -d${SEP} -f${_DATE_ACHAT_}
}

type_vin() {
    echo "$1" | cut -d${SEP} -f${_TYPE_}
}

appellation_vin() {
    echo "$1" | cut -d${SEP} -f${_APPELLATION_}
}

millesime_vin() {
    echo "$1" | cut -d${SEP} -f${_MILLESIME_}
}

nom_vin() {
    echo "$1" | cut -d${SEP} -f${_NOM_}
}

prix_vin() {
    echo "$1" | cut -d${SEP} -f${_PRIX_}
}

note_vin() {
    echo "$1" | cut -d${SEP} -f${_NOTE_}
}

commentaire_vin() {
    echo "$1" | cut -d${SEP} -f${_COMMENTAIRE_}
}
