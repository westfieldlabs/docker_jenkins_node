# docker_jenkins_node

docker_jenkins_node is a repository that builds a docker image to be used in-conjunction with Jenkins and the [Docker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin) for jenkins It is a variation of the [image](https://github.com/evarga/docker-images/blob/master/jenkins-slave/) by github user evarga Dockerfile. This image can be used in many scenarios from PR jobs to deploy jobs. It includes multiple versions of Ruby, nodejs, git and other tools one might need.

## Usage
Follow the instructions to setup the docker plugin with your jenkins instance here: [https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin)

Under the configuration section there is instuctions to add the ID of the image to use. Replace `evarga/jenkins-slave` with `westfieldlabs/docker_jenkins_node` to use this image.

Provide a "Label" for this image such as `docker`. Now load the configure page for one of your jenkins jobs: `https://<jenkinsurl>/job/<jobname>/configure`, tic the box for "Restrict where this project can be run" and enter the label you chose from before `docker`. You should now see that the "Label docker is serviced by no nodes and 1 cloud". Your job will be run in a container on the docker host you've configured using this image.

## Copyright

Copyright (c) 2016 Westfield Labs Corporation.
See [LICENSE][] for details.

[license]:      LICENSE.md