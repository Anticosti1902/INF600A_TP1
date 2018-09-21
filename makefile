###############################################################
# Constante a completer pour la remise de votre travail:
#  - CODES_PERMANENTS
###############################################################

### Vous devez completer l'une ou l'autre des definitions.   ###
# Deux etudiants: Indiquez vos codes permanents.
CODES_PERMANENTS='ABCD01020304,GHIJ11121314'

# Un seul etudiant: Supprimez le diese en debut de ligne et indiquez votre code permanent
# (sans modifier le nom de la variable).
#CODES_PERMANENTS='ABCD01020304'

########################################################################
# Constantes a modifier selon votre avancement (exemple, test) et
# selon la commande en cours de developpement.

# WIP: Exemples ou vrais tests
WIP=wip_ex    # Pour executer les exemples
#WIP=wip_test # Pour executer les vrais tests

# COMMANDE: Une commande specifique ou toutes (all)
COMMANDE=lister
#COMMANDE=ajouter
#COMMANDE=supprimer
#COMMANDE=noter
#COMMANDE=selectionner
#COMMANDE=trier
#COMMANDE=all  # Pour lancer les tests sur l'ensemble des commandes

# NIVEAU: base, intermediaire, avance ou tous les niveaux.
NIVEAU=base
#NIVEAU=intermediaire
#NIVEAU=avance
# Tous les niveaux!
#NIVEAU=tous

########################################################################
# Les cibles.
########################################################################

default: $(WIP)

wip_ex: ex_$(COMMANDE)  # ATTENTION: Certains cas ont des tests mais pas d'exemples.

wip_test: test_$(COMMANDE)

########################################################################
PGM=./gv.sh
BD=vins
########################################################################

##################################
# Cibles pour les exexmples d'execution.
##################################
ex ex_all: 
	@echo ""
	make ex_lister
	@echo ""
	make ex_ajouter
	@echo ""
	make ex_supprimer
	@echo ""
	make ex_noter
	@echo ""
	make ex_selectionner
	@echo ""
	make ex_trier

ex_ajouter: ex_init
	$(PGM) ajouter Beaujolais 2017 Foillard 22.00
	# Il devrait y avoir 5 vins, le 5e (no. 6) etant le Beaujolais
	$(PGM) lister

ex_ajouter+: ex_init
	#
	$(PGM) ajouter --qte=2 Cahors 2015 "Le Combal" 20.00
	# Il devrait y avoir 7 vins, le 6e (no. 7) et 7e (no. 8) etant le Cahors
	$(PGM) lister

ex_init:
	@cp -f $(BD).txt.init .$(BD).txt

ex_lister: ex_init
	# Il devrait y avoir 4 vins: 1, 2, 4 et 5 -- avec notes et commentaires.
	$(PGM) lister
	#
	# Il devrait y avoir 4 vins: 1, 2, 4 et 5.
	$(PGM) lister --court

ex_lister+: ex_init
	# Il devrait y avoir uniquement 4 numeros vins: 1, 2, 4 et 5.
	$(PGM) lister --format="%I"


ex_noter: ex_init
	$(PGM) noter 4 3 "Jaune assez fonce. Aromatique. Frais, rond."
	# Le vin 4 devrait maintenant etre note (3) et avec le commentaire.
	$(PGM) lister

ex_supprimer: ex_init
	$(PGM) supprimer 4
	# Il devrait y avoir 3 vins: 1, 2 et 5
	$(PGM) lister

ex_selectionner: ex_init
	# Les 4 vins devraient etre affiches
	$(PGM) selectionner

ex_selectionner+: ex_init
	# Les 2 vins bus devraient etre affiches dans la forme de la BD
	$(PGM) selectionner --bus
	#
	# Les 2 vins bus devraient etre listes
	$(PGM) selectionner --bus | $(PGM) - lister

ex_trier: ex_init
	# Les 4 vins devraient etre affiches en ordre inverse de numero.
	$(PGM) trier --reverse

ex_trier+: ex_init
	# Les 4 vins devraient etre affiches en ordre de prix.
	$(PGM) trier --prix
	#
	# Les 4 vins devraient etre affiches en ordre inverse de prix.
	$(PGM) trier --prix --reverse



##################################
# Cibles pour les vrais test.
##################################

test test_all:
	@echo "++ RESULTATS DES TESTS ++" | tee resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/init_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/init_test.rb | tee -a resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/ajouter_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/ajouter_test.rb | tee -a resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/lister_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/lister_test.rb | tee -a resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/supprimer_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/supprimer_test.rb | tee -a resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/noter_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/noter_test.rb | tee -a resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/selectionner_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/selectionner_test.rb | tee -a resultats.txt
	@#
	@echo "-- NIVEAU=$(NIVEAU) ruby Tests/trier_test.rb" | tee -a resultats.txt
	@NIVEAU=$(NIVEAU) ruby Tests/trier_test.rb | tee -a resultats.txt

test_init:
	@NIVEAU=$(NIVEAU) ruby Tests/init_test.rb
test_ajouter:
	@NIVEAU=$(NIVEAU) ruby Tests/ajouter_test.rb
test_lister:
	@NIVEAU=$(NIVEAU) ruby Tests/lister_test.rb
test_supprimer:
	@NIVEAU=$(NIVEAU) ruby Tests/supprimer_test.rb
test_noter:
	@NIVEAU=$(NIVEAU) ruby Tests/noter_test.rb
test_selectionner:
	@NIVEAU=$(NIVEAU) ruby Tests/selectionner_test.rb
test_trier:
	@NIVEAU=$(NIVEAU) ruby Tests/trier_test.rb

test_base:
	make test NIVEAU=base test_all

test_intermediaire:
	make test_all NIVEAU=intermediaire

test_avance:
	 make test_all NIVEAU=avance


##################################
# Mise a jour des permissions.
##################################
perms:
	chmod +x ./gv.sh

##################################
# Nettoyage.
##################################
clean:
	rm -f *~ *.bak
	rm -rf tmp

########################################################################
########################################################################

BOITE=INF600A

remise:
	echo "*** Ceci peut prendre quelques instants car tout le depot git est remis ***"
	PWD=$(shell pwd)
	ssh oto.labunix.uqam.ca oto rendre_tp tremblay_gu $(BOITE) $(CODES_PERMANENTS) $(PWD)
	ssh oto.labunix.uqam.ca oto confirmer_remise tremblay_gu $(BOITE) $(CODES_PERMANENTS)

########################################################################
########################################################################

