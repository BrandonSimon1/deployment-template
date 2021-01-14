# deployment-template

Templates for running a full stack app containing many connected services locally or in prodution.

## dev

This is a template for running a full stack application locally using docker-compose in a way that allows development of all the services simultaneously. It relies on 'devpod' images, which are images from some base image with git tools installed and which clone a repo provided through the environment as their main command before sleeping forever. Please see dev/docker-compose.yaml for more details.

You will attach to these containers in vscode using the remote containers extension, where you will be able to develop the service and make commits and pushes as well as running whatever command the service is supposed to run.

In this way, you can run a full stack app locally with the same sort of configuration as it would have in production while being free to change any of the code instantly within the containers and be able to commit and push those changes.

If there is poor performace when attaching to and developing in the containers, consider increasing the resources that docker has access to in the docker desktop dashboard.

To recap a bit, When you develop this way, only this deployment repo will be cloned onto your local machine's userspace; the repos of the services that make up the app will exist only in docker volumes, and you will work on them by attaching to the appropriate container. Please see dev/docker-compose.yaml for more details.

./up.sh and ./down.sh in the dev/ directory are helper scripts for running docker-compose up and down. The up one looks for an .env file in the dev/ directory. Please see dev/docker-compose.yaml for details.

## prod

This is a template for deploying a full stack app on a kubernetes cluster using kustomize. Set up a github action to run kustomize in the prod/ directory and then deploy the resulting yaml to your cluster.

Whenever you update one of the repos of the services that make up the application, change the image for that service in this repo to the new one and commit and push. (your service repos should build images tagged with the git commit hash so it will be different after every commit).

In this way deployment of the whole app is controlled by pushing this repo containing the deployment state, not the repos of any of the app's services. Pushing a repo of one of the app's services should do nothing but build and tag a new image. This new image will not get used until you update the image name for that service to the new one in this repo and push the change.

