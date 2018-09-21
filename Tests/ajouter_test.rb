require_relative 'test_helper'

date = %x{date "+%d/%m/%y"}.chomp

describe "GestionVins" do
  describe "ajouter" do
    context "cave vide" do
      it_ "ajoute dans un fichier vide" do
        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, [], :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( 'ajouter Beaujolais 2017 Foillard 22.00' )
          end
        end

        nouveau_contenu.size.must_equal 1
        nouveau_contenu.first.must_equal "1:#{date}:rouge:Beaujolais:2017:Foillard:22.00::"
      end
    end

    context "cave avec plusieurs vins" do
      let(:lignes) { IO.readlines("Tests/4vins.txt") }

      it_ "ajoute un vin, rouge par defaut" do
        appellation = "Beaujolais"
        millesime = 2017
        nom = "Foillard"
        prix = "22.00"

        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "ajouter #{appellation} #{millesime} \"#{nom}\" #{prix}" )
          end
        end

        nouveau_contenu.size.must_equal 5
        nouveau_contenu.last.must_equal "6:#{date}:rouge:Beaujolais:2017:Foillard:22.00::"
        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "ajoute un vin, d'un autre type que rouge" do
        appellation = "Chablis"
        millesime = 2017
        nom = "Laroche"
        prix = "20.00"

        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "ajouter --type=blanc #{appellation} #{millesime} \"#{nom}\" #{prix}" )
          end
        end

        nouveau_contenu.size.must_equal 5
        nouveau_contenu.last.must_equal "6:#{date}:blanc:Chablis:2017:Laroche:20.00::"
        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "ajoute plusieurs fois un meme vin", :intermediaire do
        appellation = "Chablis"
        millesime = 2017
        nom = "Laroche"
        prix = "20.00"

        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "ajouter --qte=2 --type=blanc #{appellation} #{millesime} \"#{nom}\" #{prix}" )
          end
        end

        nouveau_contenu.size.must_equal 6
        nouveau_contenu[-2].must_equal "6:#{date}:blanc:Chablis:2017:Laroche:20.00::"
        nouveau_contenu[-1].must_equal "7:#{date}:blanc:Chablis:2017:Laroche:20.00::"
        FileUtils.rm_f $DEPOT_DEFAUT
      end

      it_ "ajoute plusieurs fois un meme vin d'un autre type, avec un ordre different des options", :avance do
        appellation = "Chablis"
        millesime = 2017
        nom = "Laroche"
        prix = "20.00"

        nouveau_contenu = avec_fichier $DEPOT_DEFAUT, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "ajouter --type=blanc --qte=2 #{appellation} #{millesime} \"#{nom}\" #{prix}" )
          end
        end

        nouveau_contenu.size.must_equal 6
        nouveau_contenu[-2].must_equal "6:#{date}:blanc:Chablis:2017:Laroche:20.00::"
        nouveau_contenu[-1].must_equal "7:#{date}:blanc:Chablis:2017:Laroche:20.00::"
        FileUtils.rm_f $DEPOT_DEFAUT
      end
    end

    it_ "genere une erreur si depot inexistant", :intermediaire do
      FileUtils.rm_f $DEPOT_DEFAUT
      genere_erreur /fichier.*#{$DEPOT_DEFAUT}.*existe pas/i do
        run_gv( 'ajouter Beaujolais 2017 Foillard 22.00' )
      end
    end

    it_ "genere une erreur s'il manque des arguments", :intermediaire do
      avec_fichier $DEPOT_DEFAUT, [] do
        genere_erreur /nombre incorrect.*arguments?/i do
          run_gv( 'ajouter Beaujolais 2017 Foillard' )
        end
      end
    end

    it_ "genere une erreur si le millesime n'est pas une annee", :intermediaire do
      avec_fichier $DEPOT_DEFAUT, [] do
        genere_erreur /nombre invalide.*millesime/i do
          run_gv( 'ajouter Beaujolais 017 Foillard 22.00' )
        end
      end
    end

    it_ "genere une erreur si le prix n'est pas un montant valide", :intermediaire do
      avec_fichier $DEPOT_DEFAUT, [] do
        genere_erreur /nombre invalide.*prix/i do
          run_gv( 'ajouter Beaujolais 2017 Foillard 22' )
        end
      end
    end

    context "banque de vins autre que celle par defaut" do
      let(:lignes) { IO.readlines("Tests/4vins.txt") }
      let(:fichier) { '.foo.txt' }

      it_ "genere une erreur si depot inexistant", :intermediaire do
        FileUtils.rm_f fichier
        genere_erreur /fichier.*#{fichier}.*existe pas/i do
          run_gv( "--depot=.#{fichier} ajouter  Beaujolais 2017 Foillard 22.00" )
        end
      end

      it_ "ajoute un vin", :intermediaire do
        appellation = "Beaujolais"
        millesime = 2017
        nom = "Foillard"
        prix = "22.00"

        nouveau_contenu = avec_fichier fichier, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            run_gv( "--depot=#{fichier} ajouter #{appellation} #{millesime} \"#{nom}\" #{prix}" )
          end
        end

        nouveau_contenu.size.must_equal 5
        nouveau_contenu.last.must_equal "6:#{date}:rouge:Beaujolais:2017:Foillard:22.00::"

        FileUtils.rm_f fichier
      end
    end

    it_ "genere une erreur si on utilise stdin avec ajouter", :intermediaire do
      lignes = IO.readlines("Tests/4vins.txt")
      avec_fichier $DEPOT_DEFAUT, lignes do
        genere_erreur /stdin.*ne peut pas etre utilise/i do
          run_gv( 'selectionner --non-bus', "- ajouter" )
        end
      end
    end
  end
end
