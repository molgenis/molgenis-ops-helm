Ik beschrijf even de losse stappen die ik heb uitgevoerd want de inhoud van de nginx.tmpl verschilt vast per versie van nginx
Is gebaseerd op tip in https://github.com/kubernetes/ingress-nginx/issues/3481

# Haal de bestaande template op
kubectl cp nginx-ingress-controller-4vqbd:/etc/nginx/template/nginx.tmpl .

# Edit het ding met het handje en zet {{ $proxySetHeader }} X-Forwarded-Port       "443";

# Maak er een configmap van en stuur hem op
kubectl create cm nginx-template -n ingress-nginx --from-file=nginx.tmpl --dry-run -o yaml > nginx-template.yaml
kubectl apply -f nginx-template.yaml

# Haal de daemonset yaml op
kubectl get daemonset nginx-ingress-controller -o yaml > daemonset.yaml

# Bewerk de yaml en voeg volumeMounts en volume toe zoals beschreven op https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/custom-template/

# Deploy de bewerkte daemonset
kubectl apply -f daemonset.yaml

# Delete 1 ingress controller pod, check dat hij weer goed up komt
# Delete de ingress controller pods van de andere nodes
# Check de echo service, (brndnmtthws/nginx-echo-headers) yay!!
