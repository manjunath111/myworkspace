# Install Docker and start the Docker service based on the platform family
if platform_family?('debian')
  apt_update
  package 'apt-transport-https'

  # Add Docker's GPG key and repository to the system
  execute 'apt-key adv' do
    command 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
  end

  execute 'add-apt-repository' do
    command 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
  end

  # Install Docker CE package
  package 'docker-ce' do
    action :install
    not_if 'dpkg -s docker-ce'
  end

elsif platform_family?('rhel')
  # Add Docker's repository to the system
  yum_repository 'docker-ce' do
    baseurl 'https://download.docker.com/linux/centos/7/x86_64/stable/'
    gpgkey 'https://download.docker.com/linux/centos/gpg'
    enabled true
    gpgcheck true
  end

  # Update the system packages and install Docker CE package
  execute 'yum update -y' do
    action :run
  end

  package 'docker-ce' do
    action :install
    not_if 'rpm -qa | grep -qw docker-ce'
  end
end

# Start the Docker service based on the platform
if platform?('debian', 'ubuntu')
  service 'docker' do
    action [:enable, :start]
  end
elsif platform?('centos')
  systemd_unit 'docker.service' do
    action [:enable, :start]
  end
end

# Authenticate to the Docker Hub registry and pull the latest Nginx image
docker_registry 'https://registry.hub.docker.com' do
  username 'YourUsername'
  password 'yourDockerhubpassword'
  email 'youremail'
end

docker_image 'nginx' do
  repo 'nginx'
  tag 'latest'
  action :pull_if_missing
end

# Create and run a new Docker container based on the Nginx image
docker_container 'nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  action :run
end
