FROM ubuntu 
ARG GITHUB_PASSWORD
ARG GITHUB_USERNAME
ARG NAME
ARG EMAIL
RUN apt update -y
RUN apt install git -y
RUN git config --global credential.helper store
RUN echo "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com" >> ~/.git-credentials
RUN git config --global user.name "${NAME}"
RUN git config --global user.email "${EMAIL}"
RUN apt install postgresql-client -y
RUN apt install -y curl
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
RUN bash n lts
CMD git clone $REPO_URL /repo && cd /repo && yarn