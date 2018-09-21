require_relative 'test_helper'

describe "GestionVins" do
  describe "supprimer" do
    context "cave avec plusieurs vins" do
      let(:lignes) { IO.readlines("Tests/4vins.txt") }

      it_ "supprime le vin si le numero specifie existe" do
        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "supprimer 4" )
          end
        end

        nouveau_contenu.find { |l| l =~ /^4/ }.must_be_nil
        nouveau_contenu.size.must_equal 3

        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "genere une erreur si le numero de vin n'existe pas", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /supprimer.*6.*existe pas/i do
            run_gv( "supprimer 6" )
          end
        end
      end

      it_ "genere une erreur si le vin a deja ete note", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /1.*deja note/i do
            run_gv( "supprimer 1" )
          end
        end
      end

      it_ "genere une erreur si argument en trop", :intermediaire do
        avec_fichier $DEPOT_DEFAUT, lignes do
          genere_erreur /Nombre incorrect.*arguments?/i do
            run_gv( 'supprimer 4 foo' )
          end
        end
      end
    end

    it_ "genere une erreur si depot inexistant", :intermediaire do
      fichier = $DEPOT_DEFAUT
      FileUtils.rm_f fichier
      genere_erreur /fichier.*#{fichier}.*existe pas/i do
        run_gv( 'supprimer 2' )
      end
    end

    it_ "genere une erreur si on utilise stdin avec supprimer", :intermediaire do
      lignes = IO.readlines("Tests/4vins.txt")
      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_erreur /stdin.*ne peut pas etre utilise/i do
          run_gv( 'selectionner --non-bus', "- supprimer" )
        end
      end
    end
  end
end
