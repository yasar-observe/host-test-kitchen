# Starting from a base Ubuntu image
FROM ubuntu:20.04

# Accept the user ID and group ID as build arguments
ARG UID=1000
ARG GID=1000

# Create a group and user with the provided IDs, and create a home directory for the user
RUN groupadd -r observe -g ${GID} && \
    useradd -r -g observe -u ${UID} -m -d /home/observe -s /bin/bash observe && \
    chown -R observe:observe /home/observe

# Prevents prompting for time zone information
ARG DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    unzip \
    git \
    sudo && apt-get clean

# Add the observe user to the sudoers file and disable password requirement
RUN echo "observe ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER observe

# Import GPG keys for RVM
RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    || curl -sSL https://rvm.io/mpapis.asc | gpg --import - \
    || curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

# Install RVM, Ruby, and Bundler as 'observe' user
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=3.2.2 && \
    echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc && \
    /bin/bash -l -c "gem install bundler" && \
    /bin/bash -l -c "rvm --version" && \
    /bin/bash -l -c "ruby --version" && \
    /bin/bash -l -c "bundler --version"

# Copy your Gemfile and Gemfile.lock into the image
COPY Gemfile Gemfile.lock ./

# Install your gems
ENV BUNDLE_APP_CONFIG /home/observe/.bundle
RUN /bin/bash -l -c "bundle config network.retry 5" && \
    /bin/bash -l -c "bundle config --global no-document true" && \
    /bin/bash -l -c "bundle install --jobs $(nproc)" && \
    /bin/bash -l -c "bundle install --verbose" || \
    /bin/bash -l -c "bundle install --verbose"

# Switch back to root user to install AWS CLI and Terraform
USER root

# Install AWS CLI version 2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && aws --version

# Install Terraform
ARG TERRAFORM_VERSION=1.5.4
RUN curl -k https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin \
    && rm terraform.zip \
    && terraform --version

# Set up the working directory
WORKDIR /workdir

USER observe
COPY validate_deps.sh ./
RUN /bin/bash -c -l ./validate_deps.sh

USER root
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
