## Setup AWX on Kubernetes

> Requirements(VM) vanuit AWX-Operator:
  CPU: minimaal 4
  Memory: 6GB ram

awx-operator versie 0.15.0 is gebruikt tijdens deze setup.

Tutorial die gedeeltelijk gebruikt is:
https://computingforgeeks.com/install-and-configure-ansible-awx-on-centos/
Notitie: ik heb de persistant volume wel aangemaakt maar niet toegevoegd aan de awx_web container omdat de web data dan ontbreekt en je een niet functionerende awx hebt. 

ssh naar de vm toe
type het volgende in de cli in:
`dnf -y update && systemctl disable firewalld --now &&  reboot`

type het volgende zodra je weer in de terminal bent:
`setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config`

check via het onderstaande commando om te zien of het aangepast is en reboot voor de zekerheid
`cat /etc/selinux/config | grep SELINUX= && reboot`

voer na de reboot het volgende commando uit(dit kan even duren omdat dit k3s installeert op een vm):
`cd /root && curl -sfL https://get.k3s.io | bash -`

voer de volgende stap uit en controleer of het werkt:
`chmod 644 /etc/rancher/k3s/k3s.yaml && systemctl status k3s && kubectl get nodes && kubectl version --short`

we gaan nu de software installeren om awx-operator te kunnen deployen. voer het volgende uit:
`yum -y install git make`

we gitten de repo
`git clone https://github.com/ansible/awx-operator.git && cd awx-operator`

we gaan nu de voorbereidingen treffen voor awx-operator, voer dit uit op de command line:
`kubectl create ns awx && git checkout 0.15.0 && export NAMESPACE=awx`

de awx-operator kunnen we nu al gaan deployen. dit omdat het deployen een aantal minuten gaat duren. voer het volgende uit:
`make deploy`

maak een map aan buiten de awx-operator, zo iets als dit:
`cd ../ && mkdir kube && cd kube/`

Je kunt nu met Helm de laatste resources in dezelfde namespace deployen (namespace = awx).

`helm repo add https://registry.molgenis.org/repository/helm`
`helm install awx`
