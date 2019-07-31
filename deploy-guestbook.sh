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

printf "\nDeploying $ENV.......... \n"
git clone https://github.com/subhranildey/k8s-guestbook.git $WDIR
sh $WDIR/$ENV-deploy.sh

#To set up HPA we need to set up monitoring, so we are going to install metric-server

echo "To set up HPA we need to set up monitoring, so we are going to install metric-server"
cd $WDIR
git clone https://github.com/kubernetes-incubator/metrics-server.git

printf "\nDeploying Metrics Server for feeding in core metrics to HPA..........\n"
kubectl apply -f $WDIR/metrics-server/deploy/1.8+/

printf "\n deploy HPA.......... \n"
kubectl apply -f $WDIR/hpa.yaml --namespace=$ENV


