# Use an official AWS CLI image as the base
FROM amazonlinux:2

# Install dependencies
RUN yum -y update && \
    yum -y install \
    # unzip \
    # python3 \
    # python3-pip \
    # curl \
    jq \
    aws-cli

# Create a working directory
WORKDIR /app

# Copy the entrypoint script and CloudFormation template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
