# Install the AWS SDK for Ruby and the Docker CLI
chef_gem 'aws-sdk-ecr'

# Set up the AWS ECR client with the credentials
ecr = Aws::ECR::Client.new(
  region: 'us-west-2',
  credentials: Aws::Credentials.new('your_access_key_id', 'your_secret_access_key')
)

# Get the authentication token for ECR
auth_data = ecr.get_authorization_token.authorization_data[0]
auth_token = Base64.decode64(auth_data.authorization_token).split(':')

# Log in to ECR with the Docker CLI
execute "docker login -u #{auth_token[0]} -p #{auth_token[1]} #{auth_data.proxy_endpoint}"

# Copy the Dockerfile to the Docker build context
cookbook_file '/tmp/Dockerfile' do
  source 'Dockerfile'
  mode '0644'
end

# Build the Docker image
execute 'docker build -t myapp /tmp'

# Tag the Docker image with the ECR repository URI
execute 'docker tag myapp:latest 1234567890.dkr.ecr.us-west-2.amazonaws.com/myapp:latest'

# Push the Docker image to ECR
execute 'docker push 1234567890.dkr.ecr.us-west-2.amazonaws.com/myapp:latest'
