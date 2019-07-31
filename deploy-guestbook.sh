#!/bin/bash

DT=`date +%m-%d-%Y-%H-%M-%S`

printf "\nPlease provide the directory name where you want to clone:- \n"
read DIR

#Handle if DIR name is not provided
while [[ $DIR = "" ]]; do
   printf "\nPlease type the dir name where you want to clone the repo to continue:- \n "
   read DIR
done

WDIR=$PWD/$DIR-$DT

#Let user choose for which Environment
while true; do
    read -p "For which ENV do you want to deploy? Type P for Prod or S for Staging:- " ps
    case $ps in
        [Pp]* ) ENV=production; break;;
        [Ss]* ) ENV=staging; break;;
        * ) echo "Please type P or S";;
    esac
done
#------------------------------------Ingress-Controller---------------------------------------

#The following Mandatory Command is required for all deployments for nginx-ingress-controller
printf "\n  Setting up nginx ingress controller.....\n"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

#GCE-GKE
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
#---------------------------------------------------------------------------------------------

#--------------------------------------ENV Deployment-----------------------------------------
printf "\n  Deploying $ENV.....\n"
git clone https://github.com/subhranildey/k8s-guestbook.git $WDIR

#-----------------------------------------Deployment----------------------------------------------

kubectl apply -f $WDIR/guestbook/all-in-one/$ENV-namespace.yaml
kubectl apply -f $WDIR/guestbook/all-in-one/guestbook-all-in-one.yaml --namespace=$ENV
kubectl apply -f $WDIR/guestbook/all-in-one/$ENV-ingress.yaml

IP=$(kubectl get ing -n $ENV | grep $ENV | awk '{print $3}')

printf "\n  Wait for the $ENV IP...."

until [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    IP=$(kubectl get ing -n $ENV | grep $ENV | awk '{print $3}')
done

printf "\nMake the below entry to /etc/hosts file.....\n"

if  [ $ENV == "production" ]
then
    printf "\n$IP guestbook.mstakx.io\n"
else
    printf "\n$IP staging-guestbook.mstakx.io\n"
fi

#------------------------------------------HPA------------------------------------------------

#To set up HPA we need to set up monitoring, so we are going to install metric-server

printf "\n  To set up HPA we need to set up monitoring, so we are going to install metric-server.....\n"
cd $WDIR
git clone https://github.com/kubernetes-incubator/metrics-server.git

printf "\n  Deploying Metrics Server for feeding in core metrics to HPA.....\n"
kubectl apply -f $WDIR/metrics-server/deploy/1.8+/

printf "\n  Deploy HPA.....\n"
kubectl apply -f $WDIR/hpa.yaml --namespace=$ENV

#-------------------------------------Cleanup----------------------------------------------------
printf "\n  Deleting $WDIR.....\n"
rm -rf $WDIR

