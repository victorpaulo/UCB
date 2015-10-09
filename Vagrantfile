Vagrant.configure("2") do |config|
  
  # This sync parameter is because I have to mount redhat .iso image to install packages 
  # for IBM Installation Manager which is located on my local drive (host machine) on G: driver;
#  config.vm.synced_folder "/Volumes/My Passport", "/my_drive"
  
  
  config.vm.define "db2" do |db|
    db.vm.box = "redhat65"
	db.vm.host_name = "db2.ibm.com"
	db.vm.network "private_network", ip: "192.168.100.10"
	db.vm.network :forwarded_port, guest: 22, host: 2201, id: "ssh", auto_correct: true
	#db.vm.network "public_network"
	db.vm.provider :virtualbox do |vb|
		vb.name = "VM DB2 for UCD"
		vb.gui = false
		vb.memory = 4096
		vb.cpus = 2
	end
	db.vm.provision :shell, :path => "install_db2.sh"

  end	

  config.vm.define "urbancode" do |ucd|
    ucd.vm.box = "redhat65"
	ucd.vm.host_name = "ucd.ibm.com"
	ucd.vm.network "forwarded_port", guest: 8443, host: 8443
	ucd.vm.network "forwarded_port", guest: 8080, host: 8080
	ucd.vm.network "forwarded_port", guest: 27000, host: 27000
	ucd.vm.network "private_network", ip: "192.168.100.11"
	ucd.vm.network :forwarded_port, guest: 22, host: 2202, id: "ssh", auto_correct: true
	ucd.vm.provider :virtualbox do |vb|
		vb.name = "URBAN CODE 6.1.1"
		vb.gui = false
		vb.memory = 4096
		vb.cpus = 2
	end
	#ucd.vm.provision :shell, :path => "install.sh"

  end
end
