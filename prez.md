





-> # Web, Cloud, Puppet!

---

-> # Intro


## Objectifs

Déployer une petite application web
* dans le *cloud*
* de manière *automatique* et *scalable*
* avec des *chats* et du *fun*!


---

-> # Le cloud - késako?


Serveurs virtuels à la demande, accessible depuis une *API*.

API souvent *HTTP REST*.

Souvent on a aussi :

* Une belle interface web
 * Amazon WS Console (pas fun)
 * Cloudwatt Console (pas fun)
 * OpenStack Horizon (pas fun)
 * OVH Manager (fun, mais pas pour aujourd'hui)

* Mais aussi des outils en CLI:
 * *nova* pour nous (FUN!)


---

-> # Puppet - késako?


Puppet est un outil de *maintien / déploiement de configuration*.
Il permet d'indiquer un état voulu pour un serveur.

Puppet fonctionne en mode client <-> serveur.

Dans un réseau, il y a souvent un serveur puppet qu'on appelle le *Puppet Master*.

Les serveurs qui sont configurés par puppet doivent avoir un *Puppet Agent*.

Les VM que nous allons créer auront déjà les agents puppet d'installé.
(c'est facile à faire, mais un peu long)

---

-> # On va faire quoi?


## Que du fun


1. Se connecter à un serveur de rebond (jumphost)
2. Créer un serveur *Puppet Master* dans le cloud
3. Parametrer (pisser du code puppet) le puppet master pour
 * automatiser la configuration d'un load balancer (haproxy)
 * automatiser le déploiement d'une app web dans le cloud
4. Créer un serveur web
5. Creer un serveur web
6. Creer un serveur web
7. Creer un serveur web
...
n. creer un serveur web


---

-> # Ce qu'on va faire

                                
                                                                +-------------------+
                                                                |                   |
                                                 +------------> |   Serveur Web 1   |
                                                 |              |                   |
                                                 |              +-------------------+
                                +----------------+--+
                                |                   |           +-------------------+
                                |   Load Balancer   |           |                   |
                                |     (HA Proxy)    +---------> |   Serveur Web 2   |
                                |                   |           |                   |
                                +----------------+--+           +-------------------+
                                                 |
                                                 |              +-------------------+
                                                 |              |                   |
                                                 +------------> |   Serveur Web 3   |
                                                                |                   |
                                                                +-------------------+
                               

---


-> ## Le tout en moins d'une heure!

-> ## Le tout dans le cloud!

-> ## Et avec des chats s'il vous plait


---


                                                    /\     /\
                                                   {  `---'  }
                                                   {  O   O  }
                                                   ~~>  V  <~~
                                                    \  \|/  /
                                                     `-----'____
                                                     /     \    \_
                                                    {       }\  )_\_   _
                                                    |  \_/  |/ /  \_\_/ )
                                                     \__/  /(_/     \__/
                                                       (__/

-> ## c'est parti !


---

-> # Connexion au serveur de rebond


Linux / Mac (fun):

> ssh jump@jump.arnaudmorin.fr

Pas fun:

> putty?

Mot de passe : *moutarde*

---

-> # Rebond dans le rebond (inception!)

> ssh root@127.0.0.1 -p *22XX*

Remplacer 22XX par un port qui vous sera attribué (levez la main)

Mot de passe : *moutarde*

---

-> # List des serveurs


Sourcing de variables

> source openrc



Première utilisation de *nova* !!!

> nova list


Notre cloud est vide!

+----+------+--------+------------+-------------+----------+
| ID | Name | Status | Task State | Power State | Networks |
+----+------+--------+------------+-------------+----------+
+----+------+--------+------------+-------------+----------+



---

-> # Creation du serveur puppet

Créons maintenant notre premier serveur virtuel pour le *Puppet Master*

> nova boot --image 'puppet-breizhcamp' --flavor 'vps-ssd-2' --user-data puppet.yaml *puppet-XXX*

---

-> # ID de notre VM

Repérer l' *id* de votre VM:

+--------------------------------------+-----------------------------------------------------+
| Property                             | Value                                               |
+--------------------------------------+-----------------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                              |
| OS-EXT-AZ:availability_zone          | nova                                                |
| OS-EXT-STS:power_state               | 0                                                   |
| OS-EXT-STS:task_state                | scheduling                                          |
| OS-EXT-STS:vm_state                  | building                                            |
| OS-SRV-USG:launched_at               | -                                                   |
| OS-SRV-USG:terminated_at             | -                                                   |
| accessIPv4                           |                                                     |
| accessIPv6                           |                                                     |
| adminPass                            | BNciuqe2uoC2                                        |
| config_drive                         |                                                     |
| created                              | 2016-03-10T21:21:41Z                                |
| flavor                               | vps-ssd-1 (550757b3-36c2-4027-b6fe-d70f45304b9c)    |
| hostId                               |                                                     |
| id                                   | *5e6f1ff1-d672-47c8-b6ad-8dd0ae4121fa*                |
| image                                | Ubuntu 14.04 (6ea6402b-accd-487f-9ff5-175ecebfd10b) |
| key_name                             | -                                                   |
| metadata                             | {}                                                  |
| name                                 | puppet                                              |
| os-extended-volumes:volumes_attached | []                                                  |
| progress                             | 0                                                   |
| security_groups                      | default                                             |
| status                               | BUILD                                               |
| tenant_id                            | 7aaf74de54834425af0abfb93a6b9d79                    |
| updated                              | 2016-03-10T21:21:41Z                                |
| user_id                              | ff036f82608e491887221f048d305056                    |
+--------------------------------------+-----------------------------------------------------+

*Ne perdez pas votre ID!!!*


---

-> # Afficher les infos de votre Puppet Master

> nova show *5e6f1ff1-d672-47c8-b6ad-8dd0ae4121fa*


+--------------------------------------+----------------------------------------------------------+
| Property                             | Value                                                    |
+--------------------------------------+----------------------------------------------------------+
| Ext-Net network                      | *158.69.78.161*                                            |
| OS-DCF:diskConfig                    | MANUAL                                                   |
| OS-EXT-AZ:availability_zone          | nova                                                     |
| OS-EXT-STS:power_state               | 1                                                        |
| OS-EXT-STS:task_state                | -                                                        |
| OS-EXT-STS:vm_state                  | active                                                   |
| OS-SRV-USG:launched_at               | 2016-03-10T21:22:37.000000                               |
| OS-SRV-USG:terminated_at             | -                                                        |
| accessIPv4                           |                                                          |
| accessIPv6                           |                                                          |
| config_drive                         |                                                          |
| created                              | 2016-03-10T21:21:41Z                                     |
| flavor                               | vps-ssd-1 (550757b3-36c2-4027-b6fe-d70f45304b9c)         |
| hostId                               | d2e4ad10973097e45f5ea0b9914acdcbe5e7a4eb1ccac74adacec825 |
| id                                   | 5e6f1ff1-d672-47c8-b6ad-8dd0ae4121fa                     |
| image                                | Ubuntu 14.04 (6ea6402b-accd-487f-9ff5-175ecebfd10b)      |
| key_name                             | -                                                        |
| metadata                             | {}                                                       |
| name                                 | puppet                                                   |
| os-extended-volumes:volumes_attached | []                                                       |
| progress                             | 0                                                        |
| security_groups                      | default                                                  |
| status                               | ACTIVE                                                   |
| tenant_id                            | 7aaf74de54834425af0abfb93a6b9d79                         |
| updated                              | 2016-03-10T21:22:37Z                                     |
| user_id                              | ff036f82608e491887221f048d305056                         |
+--------------------------------------+----------------------------------------------------------+


---

-> # Connexion à votre serveur

> ssh *adresse_ip*

Mot de passe : *moutarde*


---

-> # Vérification du status

> service puppetserver status

*puppetserver is running*


Nous avons un Puppet Master en route !!!


---

-> # Observons un peu le code puppet

> cd /etc/puppetlabs/code/environments/production


Dossiers:
* *manifests*
 * contient les "manifests" qui décrivent l'état d'un noeud (un serveur)
* *modules*
 * contient un ensemble de manifests, fichiers, templates pour installer
   et/ou configurer un composant sur un noeud

Pour représenter la *configuration* d'un serveur, on écrit donc des *modules* (ou
on les télécharge parce qu'on est des fainéants de développeurs) qui sont ensuite
inclus par les *manifests*.

On appelle *catalogue* la compilation de l'ensemble des manifests / modules qui
représentent l'état cible d'un serveur.



Liste des modules pré-installés sur ce serveur :

> ls modules

 apt  concat  epel  firewall  haproxy  inifile  postgresql  puppetdb  python  stdlib  vcsrepo



Tous ces modules ont été récupéré sur la forge de puppetlabs et installés avec:

> puppet module install *nom_du_module*

---

-> # Manifest

> vim manifests/site.pp

---

-> # Démarrage de l'agent puppet pour voir ce qu'il fait

> puppet agent -t -v


Hello world, le reste est déjà configuré.

---

-> # Boot d'un serveur web


On ouvre un nouveau terminal SSH, on se connecte au rebond:
------

> ssh jump@jump.arnaudmorin.fr 


Puis au rebond inception:
---------

> ssh root@127.0.0.1 -p *22XX*

Sourcing de l'environnement nova:
----------

> source openrc

Enfin on boot notre serveur web:
---------

> nova boot --image 'Ubuntu 14.04' --flavor 'vps-ssd-1' --user-data web.yaml *web-XXX*

*On note bien l'id de notre serveur*


Pendant qu'il boot, regardons le fichier de postinstall
------

> cat web.yaml

---

-> # On se connecte sur le web server

On récupere son ip avec:

> nova show *id*

Puis:

> ssh *adresse_ip*


Avant de lancer puppet, regardons les cronjob d'installés:

> crontab -l


On déclare puppet dans le fichier hosts:

> echo " *adresse_ip_puppet* puppet" >> /etc/hosts

Puis, on lance puppet sur le serveur web:

> puppet agent -t -v


Et maintenant, crontab:

> crontab -l

---

-> # Installation du serveur web

Pour le moment, notre *serveur web est vide*. Ecrivons un peu de *code puppet* pour y installer
le necessaire *python*.

On ajoute dans la partie du noeud "web":


      # Installation du nécessaire pour python
      class { 'python' :
        version    => 'system',
        pip        => 'present',
        dev        => 'absent',
        virtualenv => 'absent',
        gunicorn   => 'absent',
      }
        
      # Installation de Flask (genre de serveur web pour python)
      python::pip { 'Flask': }



*Ou bien, pour aller vite*

> cd /etc/puppetlabs/code/environments/production
> git checkout bz2


On peut observer ce qui se passe sur le serveur web avec:

> tailf /var/log/syslog | ccze -A

---

-> # Installation de l'application web

Maintenant installons l'application web.
En réalité elle sera récupérer depuis github:

      # Install python web application
      package { 'git':
        ensure    => 'latest',
      }
      ->
      vcsrepo { '/opt/demoflask':
        ensure    => latest,
        provider  => git,
        source    => 'https://github.com/arnaudmorin/puppet-demoflask.git',
      }
      ->
      exec { '/opt/demoflask/start.py &':
        unless    => '/bin/pidof -x start.py',
        require   => Python::Pip['Flask'],
      } 


*Ou bien, pour aller vite*

> cd /etc/puppetlabs/code/environments/production
> git checkout bz3


On peut maintenant observer qu'une *application web tourne sur le port 5000* !!!
On peut s'y rendre avec notre navigateur web !!!


---

-> # Haproxy sur le puppet master

Si on démarre un *second serveur web* pour absorber la charge, il sera maintenant
*automatiquement configuré* comme le premier (avec l'application web qui écoute sur le port
5000).

Nous allons maintenant utiliser notre serveur puppet comme serveur web frontal avec *haproxy*, 
simplement pour faire du *load-balancing* (round robin).

---

-> # Installation haproxy

Ajoutons dans la partie du noeud puppet:


      # install and configure haproxy
      class { 'haproxy': }
    
      haproxy::listen { 'stats':
        ipaddress        => $::ipaddress,
        ports            => '9090',
        options          => {
          'mode'  => 'http',
          'stats' => [
            'uri /'
          ],
        },
      }
    
      haproxy::listen { 'web':
        ipaddress        => $::ipaddress,
        ports            => '80',
        options          => {
          'option'  => ['tcplog'],
          'balance' => 'roundrobin',
        },
      }


*Ou bien, pour aller vite*

> cd /etc/puppetlabs/code/environments/production
> git checkout bz4

On peut observer ce qui se passe sur le puppet master avec:

> tailf /var/log/syslog | ccze -A

Nous avons maintenant un  *load balancer* qui écoute sur le port 80 de notre serveur puppet.
Il écoute aussi sur le port 9090 (pour avoir des stats a propos du load balancer).


---

-> # Déclaration d'un backend

Le frontend du load balancer est configuré, mais il n'a encore aucun backend de défini.
Déclarons notre serveur web comme backend, dans la partie du noeud "web":

      # declare haproxy backend
      @@haproxy::balancermember { $::fqdn:
        listening_service => 'web',
        ipaddresses       => $::ipaddress,
        server_names      => $::hostname,
        ports             => '5000',
        options           => 'check',
      }


*Ou bien, pour aller vite*

> cd /etc/puppetlabs/code/environments/production
> git checkout bz5

*Rendons nous maintenant sur le port 80 de notre frontal load balacancer (adresse IP du*
*serveur puppet)*

---








->  Victoire
----------

---


-> # BONUS: Spawn d'autres serveurs web

Modifier web.yaml pour automatiser la création du fichier /etc/hosts

> vim web.yaml

Décommenter et remplacer l'adresse ip par l'adresse du puppet master :

>     - echo "149.202.165.157 puppet" >>/etc/hosts
>     - /opt/puppetlabs/bin/puppet agent -t -v      



> nova boot --image 'Ubuntu 14.04' --flavor 'vps-ssd-1' --user-data web.yaml
> --num-instances 3 web


---






-> Merci pour votre participation

-> Arnaud Morin 
-> OVH
