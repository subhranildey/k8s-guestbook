#!/bin/bash

DT=`date +%m-%d-%Y-%H-%M-%S`

echo "Please provide the directory name where you want to clone:- "
read DIR

#Handle if DIR name is not provided
while [[ $DIR = "" ]]; do
   echo "Please type the dir name where you want to clone the repo to continue:- "
   read DIR
done

WDIR=$PWD/$DIR

#Let user choose for which Environment
while true; do
    read -p "For which ENV do you want to deploy? Type P for Prod or S for Staging:- " ps
    case $ps in
        [Pp]* ) ENV=production; break;;
        [Ss]* ) ENV=staging; break;;
        * ) echo "Please type P or S";;
    esac
done

echo "Deploying $ENV"

#Checkt if DIR and File exists
if [ -d "$DIR" ]; then
        if [ -e $DIR/"$ENV-deploy.sh" ]; then
            cd $DIR
            sh $ENV-deploy.sh
            exit
        else
            #Handle non empty directory
            echo $DIR in not empty, Backing it up at $DIR-BKP-$DT
            mv $DIR $DIR-BKP-$DT
            git clone https://github.com/subhranildey/examples.git $DIR
        fi
    cd $DIR
    sh $ENV-deploy.sh
#If Dir not exist
else
    git clone https://github.com/subhranildey/examples.git $DIR
    cd $DIR
    sh $ENV-deploy.sh
fi

#To set up HPA we need to set up monitoring, so we are going to install metric-server

echo "To set up HPA we need to set up monitoring, so we are going to install metric-server"
cd $WDIR/metrics-server
git clone https://github.com/kubernetes-incubator/metrics-server.git

echo -e "\nDeployingii Metrics Server for feeding in core metrics to HPA"
kubectl apply -f metric-server/deploy/1.8+/

echo -e "\n deploy HPA"
kubectl apply -f hpa.yaml --namespace=$ENV


