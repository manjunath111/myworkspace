# Install the AWS SDK for Ruby
chef_gem 'aws-sdk-ecr'

# Load the AWS credentials from a Chef data bag
aws_creds = data_bag_item('aws', 'credentials')

# Set up the AWS ECR client with the credentials
ecr = Aws::ECR::Client.new(
  region: 'us-west-2',
  access_key_id: aws_creds['access_key_id'],
  secret_access_key: aws_creds['secret_access_key']
)

# Get the authentication token for ECR
auth_data = ecr.get_authorization_token.authorization_data[0]
auth_token = Base64.decode64(auth_data.authorization_token).split(':')

# Log in to ECR with the Docker CLI
execute "docker login -u #{auth_token[0]} -p #{auth_token[1]} #{auth_data.proxy_endpoint}"

# Pull the Docker image from ECR
docker_image '1234567890.dkr.ecr.us-west-2.amazonaws.com/myapp' do
  tag 'latest'
end
