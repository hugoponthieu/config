# Configuration de poste avec chezmoi

Ce dépôt restaure les configurations utilisateur et les paquets d'un poste
Arch Linux. Les fichiers sont organisés selon les conventions de
[chezmoi](https://www.chezmoi.io/) : par exemple,
`dot_config/hypr/hyprland.conf` est appliqué dans
`~/.config/hypr/hyprland.conf`.

## Nouvelle installation

Installer les deux dépendances nécessaires au démarrage, puis laisser chezmoi
faire le reste :

```sh
sudo pacman -S --needed chezmoi git
chezmoi init --apply https://github.com/hugoponthieu/config.git
```

La première application :

1. installe et met à jour les paquets officiels listés dans
   `.chezmoitemplates/packages-repo.txt` ;
2. installe `yay` si nécessaire, puis les paquets AUR listés dans
   `.chezmoitemplates/packages-aur.txt` ;
3. applique Hyprland, Kitty, Neovim, tmux, Waybar et Wofi ;
4. installe TPM et les plugins déclarés dans `.tmux.conf` ;
5. installe la configuration de greetd dans `/etc/greetd` et active son
   service pour le prochain démarrage.

Les scripts sont relancés uniquement lorsque leurs listes ou leurs fichiers
sources changent. Les étapes système demandent le mot de passe `sudo`. Le service greetd est
activé, mais n'est pas démarré pendant la session en cours.

Pour essayer cette branche avant sa fusion :

```sh
chezmoi init --branch feat-chezmoi --apply https://github.com/hugoponthieu/config.git
```

## Utilisation courante

Voir les changements avant de les appliquer :

```sh
chezmoi diff
chezmoi apply
```

Modifier un fichier géré :

```sh
chezmoi edit ~/.config/hypr/hyprland.conf
chezmoi apply
```

Importer une modification faite directement dans le fichier actif :

```sh
chezmoi add ~/.config/hypr/hyprland.conf
```

Mettre le dépôt à jour sur une nouvelle machine :

```sh
chezmoi update
```

Les listes de paquets et les fichiers de greetd sont placés dans
`.chezmoitemplates` afin qu'ils restent disponibles pour les scripts sans être
copiés directement dans le dossier personnel.

### Synchroniser les paquets avant une réinstallation

Le manifeste contient tous les paquets installés explicitement sur la machine,
séparés entre dépôts officiels et AUR/paquets locaux. Pacman réinstalle
automatiquement leurs dépendances, ce qui reconstitue l'ensemble sans figer
des dépendances transitoires obsolètes.

Après avoir installé ou supprimé un paquet, mettre le manifeste à jour avec :

```sh
./update-packages.sh
git diff -- .chezmoitemplates/packages-*.txt
```

Le script conserve aussi `chezmoi` dans la liste officielle, car il fait partie
du mécanisme de restauration même s'il n'était pas encore installé au moment
de l'inventaire. Les sous-paquets `*-debug` ne sont pas listés séparément : ils
sont régénérés avec leur paquet AUR source par `makepkg`.

## Données volontairement exclues

Le dépôt ne doit pas contenir de clés SSH, de jetons, de mots de passe, de
fichiers cloud/Kubernetes ou d'autres secrets. Ils doivent être sauvegardés
séparément dans un gestionnaire de mots de passe ou être ajoutés plus tard avec
le chiffrement `age` de chezmoi.
