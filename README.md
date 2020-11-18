vagrant-docker
==============

Création d'une VM (ubuntu) avec une instance de docker prête à l'emploi

Pré-requis
----------

Les outils suivants doivent être installé sur le poste de travail :

- **[Installer Chocolatey](https://chocolatey.org/docs/installation#installing-behind-a-proxy)**: cette outil permet d’installer une ou plusieurs applications dans leur dernière version disponible, de les mettre à jour ou les désinstaller en une seule commande

- **[Installer Cmder](https://cmder.net/)**: Cmder est un outil de ligne de commande, il permet de remplacer avantageusement cmd fournit par défaut par Windows


Une fois ces outils mis en place, vous devez installer les outils appelés par le projet. Ces installations se font simplement en utilisant la commande `choco install`

    choco install -y virtualbox --params "/NoDesktopShortcut /NoExtensionPack"
    choco install -y make vagrant docker-cli docker-compose

Pour permettre à Vagrant de changer la taille du disque de la VM, il est nécessaire d'installé le plugin `vagrant-disksize` :

```bash
vagrant plugin install vagrant-disksize
```

Usage de la VM
--------------

Démarrer la machine virtuelle

    make vm-up

Arrêter la machine virtuelle

    make vm-halt

Supprimer la machine virtuelle, ainsi que tous les fichiers auto-générés

    make vm-clean

Pour connaître toutes les commandes disponibles

    make help


Usage de docker
----------------

Docker est installé sur la vm en exposant son API de façon sécurisé (TLS). Pour y accéder avec le docker-cli, vous devez configurer les variables d'environnement suivantes DOCKER_HOST, DOCKER_TLS_VERIFY et DOCKER_CERT_PATH

Pour connaitre les valeurs de ces variables, utilisez la commande suivante :

```
[localhost]# make docker-env
------------------------------------------------------
To use docker, you have to define environment variable as the following :

DOCKER_HOST=tcp://192.168.56.10:2376
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=C:/Users/<USERNAME>/.docker/local
------------------------------------------------------
```

Partage de dossier entre host et la VM
----------------------------------------

Pour des raisons de confort, un certain nombre de répertoire du poste de travail sont partagés avec la VM :



| Variable          | Valeur par défaut        | Description                                                  |
| ----------------- | ------------------------ | ------------------------------------------------------------ |
| DEV_HOME          | d:/Projects              | Contient les sources des projets. Très pratique si on souhaite créer des volumes locaux au projet en utilisant des chemins relatifs avec docker-compose |
| USER_HOME         | $(USERPROFILE)           | Contient le profil utilisateur. Nécessaire pour y déposer les certificats TLS pour docker dans `$USER_HOME/.docker/local` |
| VAGRANT_MEMORY    | 2048                     | Memoire RAM alloué pour la VM Vagrant                        |
| VAGRANT_CPU       | 2                        | Nombre de VCPU alloués à la VM                               |
| VAGRANT_DISK_SIZE | 20GB                     | Taille du disque de la VM (exprimé en MB ou GB)              |


Ces variables peuvent être redéfinies en créant un fichier .env à la racine de ce projet.

