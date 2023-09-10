#! /bin/bash

#       Objectif : créer et afficher un tableau contenant les noms, tailles et 
#la date de création des fichiers d'un répertoire et modifier une trace de
#l'exécution du programme dans un fichier .log
#       Prérequis :
#               -1 argument: un répertoire(le répertoire /home/user par défaut)
#       Exécution : ./rep.sh Repertoire

#1.REMPLISSAGE DES TABLEAUX

#Création des tableaux associatifs 'tailleTab' et 'nom'
declare -A tailleTab

declare -A nom

#Compte le nombre de fichier dans le répertoire et stocker le résultat
#Sert aussi de clé dans le tableau associatif
let cmpt=0

#Changement de répertoire de travail vers répertoire en paramètre
cd $1

#Boucle for afin de remplir les tableaux
#On parcours chaque élément de ls -lt du plus petit au récent(date de création)

for i in $(ls -lt --time=birth -m -r); do
	#On enlève les virgules du nom pour remplir le tableau 'nom'
	nomVrai=$(echo $i | sed 's/,//')
	
	#On trouve la taille en octets des fichiers
        taille=$(stat -c '%s' $nomVrai)

	#Convertir en kilo octet si la taille du fichier >= 1 octet
        if [[ $taille -ge 1000 ]]; then

		#On utilise la méthode 'bc' afin de convertir en kilo octet
                conTaille=$(bc <<< "scale=2;$taille/1000")

		#On rajoute k à la fin du chiffre convertit
                tailleFin="${conTaille}k"
        else
		#On laisse la taille en octet
                tailleFin="$taille"

        fi
	#On ajoute la taille à 'tailleTab' avec pour clé cmpt
        tailleTab+=([$cmpt]="$tailleFin")

	#On ajoute le nom sans virgule à 'nom' avec pour clé cmpt
        nom+=([$cmpt]="$nomVrai")

	#On rajoute 1 à cmpt
        let cmpt+=1
done

#Stocker le nom du script avec le répertoire passé en paramètre. Type chaine decaractère
SCRIPTARG="$0 $1" #$0 = nom du script. $1 = nom du répertoire en paramètre

#Stocker la date d'exécution du script (Format AnnéeMoisJourHeureMinute)
DATEEXE=$(date +%Y%m%d%H%M)

#Générer le log et le stocker dans une variable
#$USER = Utilisateur, $PWD = Chemin d'accès du répertoire actuel
LOG="$DATEEXE $USER $PWD $SCRIPTARG($cmpt)"

#Afficher le log
echo "$LOG :"

#2. AFFICHAGE DU TABLEAU

#On affiche le nom des colonnes
printf "%-30s | %-10s | %-20s\n" "Nom" "Taille" "Date création"

cmpt2=0

#Boucle while allant de 0 à cmpt(nb de fichiers dans le tableau) non inclus

while [[ $cmpt2 -lt $cmpt ]]; do

	#on assigne l'élément qui a la clé cmpt2 à nomFichier
        nomFichier=${nom[$cmpt2]}

	#on trouve la date de création du fichier avec stat et awk
	dateFichier=$(stat -c %w "$nomFichier"|awk '{print $1}')

	#on met la date au format jj mmm aaaa
	dateFichierFormat=$(date -d $dateFichier '+%d %b %Y')

	#on affiche les éléments lignes par lignes dans les colonnes
        printf "%-30s | %-10s | %-20s\n" "${nom[$cmpt2]}" "${tailleTab[$cmpt2]}" "$dateFichierFormat"
	
	#on ajoute 1 à cmpt2
        let cmpt2+=1

done

#Retour au répertoire home/user pour ajouter le log à rep.log
cd

#3. MODIFICATION DU FICHIER rep.log

#Ajouter le log au fichier rep.log (le créer si celui-ci n'existe pas)
echo "$LOG" >> rep.log
#fin
