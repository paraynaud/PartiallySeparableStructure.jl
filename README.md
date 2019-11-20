test
# Build & Code coverage

[![Build Status](https://travis-ci.com/paraynaud/PartiallySeparableStructure.jl.svg?branch=master)](https://travis-ci.com/paraynaud/PartiallySeparableStructure.jl)

[![Coverage Status](https://coveralls.io/repos/github/paraynaud/PartiallySeparableStructure.jl/badge.svg?branch=master)](https://coveralls.io/github/paraynaud/PartiallySeparableStructure.jl?branch=master)


# PartiallySeparableStructure.jl
package ayant pour but d'obtenir la structure partiellement séparable d'une Expr



# Philosophie:

J'ai essayé de faire un outil en julia en utilisant l'interface (façade) issue des principes de la programmation objet. Le but étant de coder les algos de principe une seule fois. À partir de là il faut que mes structures de données et les objets que je manipule implémente les fonctions de base dont j'ai besoin pour les algos.
Mais globalement je manipule des arbres ainsi les fonctions de bases sont relativement simple.


# Implications:

Mon projet n'est donc pas structuré de la même manière que les projets julia classique, j'ai découpé mon projet en répertoire qui implémente chacun un "objet". À l'heure actuelle il y a par exemple :
  - un répertoire tree. Il implémente une manière de coder des arbres. Pour représenter les constructeurs et un semblant de classe abstraite il y a le type abstrait ab_tree.
  On y retrouver également une implémentation concrète des arbres dans le fichier impl_tree.jl. Cependant je voulais également considérer le type Expr déjà présent dans julia comme un arbre. Ce type ne pouvant pas être un sous-type du type abstrait que j'ai défini, j'ai donc utilisé les traits pour l'ajouter comme un type héritant du comportement des arbres. Je veille cependant à lui implémenter un constructeur défini dans le module du type abstrait.
  Les fonctions de base dont j'aurais besoin sont elles définies dans le trait des arbres, dans le fichier tr_tree.jl. On veille à ce que les fonctions prennent bien en arguments des types inclus dans le trait. Toutes les fonctions définies dans le trait se retrouvent donc dans les modules implémentant ce trait étant des sous-types ou non du type abstrait (impl_tree.jl et impl_tree_Expr.jl) en implémentant les fonctions pour un type bien précis. Pour se facilité la tâche lors d'ajout de nouveau module je définis les fonctions devant être implémenté dans itf_tree.jl faisant office d'interface de manière à "include" le fichier du trait après ceux des fichiers implémentant le trait.
  Pour finir si l'on veut utiliser l'outil il est nécessaire d'appeler les fichier dans le bon ordre, raison pour laquelle on retrouve dans chaque répertoire un fichier ordered_include.jl.




# Points tricky:

- Pour récapituler mes structures de données possède une interface et sont coder dans des répertoires différents, cependant certaines d'entre elles sont dépendantes, il faut donc bien faire attention à comment appeler quel répertoire est appelé en premier, d'où le ordered_include.jl dans le répertoire src.
- J'ai aussi essayé de faire en sorte que chaque méthode dépendant de structure/interface particulière soit codé au plus près de la définition des structures/interfaces en question. Les algorithmes sont donc écris dans le même fichier que les traits mais dans un module différents qui possède également des import/using différents.
- J'avais des problèmes avec les includes classique, par rapport aux environnements. J'ai donc du utiliser des import ..<nom_de_module>, raison pour laquelle il est nécessaire que les modules en question soient bien à jour si ils sont modifié. Il est alors plus simple de lancer le oredered_include.jl du répertoire source ou alors de lancer les tests.


# Similarités :
- Les traits sont des interfaces, mais du à des problèmes liés à la syntaxe du language ils ne sont pas appelé comme tel. Les traits définissent des méthodes abstraites.
- Les ordered_include.jl font office de makefile et sous makefile.
- Les modules définissant des type abstraits font offices de "classe abstraite"
