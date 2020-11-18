# ========================================================
# makefile
# ========================================================
default: help	# default target
.ONESHELL:		# https://www.gnu.org/software/make/manual/html_node/One-Shell.html
FORCE:			# https://www.gnu.org/software/make/manual/html_node/Force-Targets.html

# --------------------------------------------------------
# Include master project makefile
# --------------------------------------------------------

# Includes custom vars
-include .env

# --------------------------------------------------------
# Overridable variables
# --------------------------------------------------------

# version of package
VERSION_DOCKER       ?= 19.03.5
VERSION_COMPOSE      ?= 1.25.4
VERSION_CONTAINERD 	?= 1.2.10-2

# Customize virtual machine config
DOCKER_IP 		?= 192.168.56.10
VAGRANT_VCPU 	?= 2
VAGRANT_MEMORY 	?= 2048
VAGRANT_DISK_SIZE ?= 20GB

# Users PATH (use / instead '\' in path)
DEV_HOME ?= d:/Projects
USER_HOME ?= $(USERPROFILE)

# -----------------------------------------------------------------------------
# Internals variables
# -----------------------------------------------------------------------------

# Env vars for docker cli
DOCKER_HOST=tcp://$(DOCKER_IP):2376
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=$(USER_HOME)/.docker/local

# Folder to store downloaded packages
PKG_DEST_PATH = .download

# URLs to find docker package and dependencies
URL_DOWNLOAD_DOCKER=https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64
URL_DOWNLOAD_COMPOSE=https://github.com/docker/compose/releases/download/$(VERSION_COMPOSE)

# Name of package file to dowload
PKG_FILE_DOCKER_CE=docker-ce_$(VERSION_DOCKER)~3-0~ubuntu-bionic_amd64.deb
PKG_FILE_DOCKER_CE_CLI=docker-ce-cli_$(VERSION_DOCKER)~3-0~ubuntu-bionic_amd64.deb
PKG_FILE_CONTAINERD=containerd.io_$(VERSION_CONTAINERD)_amd64.deb
PKG_FILE_COMPOSE=docker-compose-Linux-x86_64

# Path of dowloaded package file
DEST_PATH_DOCKER_CE 	:= $(PKG_DEST_PATH)/$(PKG_FILE_DOCKER_CE)
DEST_PATH_DOCKER_CE_CLI := $(PKG_DEST_PATH)/$(PKG_FILE_DOCKER_CE_CLI)
DEST_PATH_CONTAINERD	:= $(PKG_DEST_PATH)/$(PKG_FILE_CONTAINERD)
DEST_PATH_COMPOSE		:= $(PKG_DEST_PATH)/$(PKG_FILE_COMPOSE)-${VERSION_COMPOSE}

# commands
CMD_DOCKER=docker
CMD_VAGRANT=vagrant

# Vars export for Vagrantfile
DEV_HOME_WIN=$(shell cygpath -m -a $(DEV_HOME))
DEV_HOME_LINUX=/$(shell cygpath -a $(DEV_HOME))

USER_HOME_WIN=$(shell cygpath -m -a $(USER_HOME))
USER_HOME_LINUX=/$(shell cygpath -a $(USER_HOME))

DOCKER_CERT_PATH_WIN=$(shell cygpath -m -a $(DOCKER_CERT_PATH))
DOCKER_CERT_PATH_LINUX=/$(shell cygpath -a $(DOCKER_CERT_PATH))

export
# ========================================================
# Targets
# ========================================================

# Inner target to download docker-ce
$(DEST_PATH_DOCKER_CE):
	mkdir -p $(PKG_DEST_PATH)
	echo "Getting $(PKG_FILE_DOCKER_CE)..."
	curl -L "$(URL_DOWNLOAD_DOCKER)/$(PKG_FILE_DOCKER_CE)" -o $(DEST_PATH_DOCKER_CE)

# Inner target to download docker-ce-cli
$(DEST_PATH_DOCKER_CE_CLI):
	mkdir -p $(PKG_DEST_PATH)
	echo "Getting $(PKG_FILE_DOCKER_CE_CLI)..."
	curl -L "$(URL_DOWNLOAD_DOCKER)/$(PKG_FILE_DOCKER_CE_CLI)" -o $(DEST_PATH_DOCKER_CE_CLI)

# Inner target to download containerd
$(DEST_PATH_CONTAINERD):
	mkdir -p $(PKG_DEST_PATH)
	echo "Getting $(PKG_FILE_CONTAINERD)..."
	curl -L "$(URL_DOWNLOAD_DOCKER)/$(PKG_FILE_CONTAINERD)" -o $(DEST_PATH_CONTAINERD)

# Inner target to download docker-compose
$(DEST_PATH_COMPOSE):
	mkdir -p $(PKG_DEST_PATH)
	echo "Getting $(PKG_FILE_COMPOSE)..."
	curl -L "$(URL_DOWNLOAD_COMPOSE)/$(PKG_FILE_COMPOSE)" -o $(DEST_PATH_COMPOSE)

# Inner target to download all binaries
downloads: 	$(DEST_PATH_DOCKER_CE) \
			$(DEST_PATH_DOCKER_CE_CLI) \
			$(DEST_PATH_CONTAINERD) \
			$(DEST_PATH_COMPOSE) 

# Inner target to generate setenv.bat
setenv:
	@echo "set DOCKER_HOST=$(DOCKER_HOST)" >setenv-docker.bat
	@echo "set DOCKER_TLS_VERIFY=$(DOCKER_TLS_VERIFY)" >>setenv-docker.bat
	@echo "set DOCKER_CERT_PATH=$(DOCKER_CERT_PATH)" >>setenv-docker.bat
	@echo "set COMPOSE_CONVERT_WINDOWS_PATHS=1" >>setenv-docker.bat

# --------------------------------------------------------
##@ Project task
# --------------------------------------------------------

check: ## Cehck requirements
	@[ $$( which vagrant 2>/dev/null ) ] || { echo "Vagrant must be installed. Uses command like 'choco install vagrant'"; exit 1; }
	@[ $$( which make 2>/dev/null ) ] 		|| { echo "GNUMake must be installed. Uses command like 'choco install make'"; exit 1; }

prepare: check downloads setenv ## Download all binaries and prepare all required folders
	@echo "export PKG_FILEPATH_DOCKER_CE=/vagrant/$(DEST_PATH_DOCKER_CE)" > $(PKG_DEST_PATH)/configure.sh
	@echo "export PKG_FILEPATH_DOCKER_CE_CLI=/vagrant/$(DEST_PATH_DOCKER_CE_CLI)" >> $(PKG_DEST_PATH)/configure.sh
	@echo "export PKG_FILEPATH_CONTAINERD=/vagrant/$(DEST_PATH_CONTAINERD)" >> $(PKG_DEST_PATH)/configure.sh
	@echo "export PKG_FILEPATH_COMPOSE=/vagrant/$(DEST_PATH_COMPOSE)" >> $(PKG_DEST_PATH)/configure.sh
	@echo "All required packages are downloaded in $(PKG_DEST_PATH)"

# --------------------------------------------------------
##@ Docker management task
# --------------------------------------------------------

docker: FORCE ## Execute docker command with given parameters (Ex: make docker -- ps -a)
	@$(CMD_DOCKER) $(filter-out $@,$(MAKECMDGOALS))

docker-clean: ## Clean all resources in the docker engine
	$(CMD_DOCKER) stack rm $$(docker stack ls  --format "{{.Name}}")
	$(CMD_DOCKER) stop $$(docker ps -aq) || echo "Nothing to do"
	$(CMD_DOCKER) stop $$(docker ps -aq) || echo "Nothing to do"
	$(CMD_DOCKER) rm $$(docker ps -aq) || echo "Nothing to do"
	$(CMD_DOCKER) system prune -a -f
	$(CMD_DOCKER) volume prune -f

docker-env: ## Displays env variable and their values to use docker from other project
	@echo "#------------------------------------------------------"
	echo "# To use docker, you have to define environment variable as the following."
	echo "# Copy and paste the below values into your command prompt"
	echo "#"
	cat ./setenv-docker.bat
	echo "#------------------------------------------------------"


# --------------------------------------------------------
##@ VM managment tasks
# --------------------------------------------------------

vm: ## Alias to call vagrant CLI command (Ex: make vm -- up)
	$(CMD_VAGRANT) $(filter-out $@,$(MAKECMDGOALS))

vm-up: prepare ## Starts VM with vagrant
	$(CMD_VAGRANT) up && $(MAKE) docker-env

vm-halt: ## Stops VM with vagrant
	$(CMD_VAGRANT) halt

vm-destroy: ## Removes the VM
	$(CMD_VAGRANT) destroy -f

vm-status: ## Displays the status of the VMs
	vagrant status;

vm-ssh: ## Open ssh session on the VM
	$(CMD_VAGRANT) ssh $(if $(dir), -c "cd $(dir) && sudo bash",)

vm-clean: vm-destroy ## Deletes VM ans all files generated by vagrant
	rm -fR .vagrant
	rm -f *console.log
	rm -fR $(DOCKER_CERT_PATH)

# --------------------------------------------------------------
##@ VM provisioning tasks
# --------------------------------------------------------------

prov-bootstrap: ## Provisions system upgrade
	$(CMD_VAGRANT) provision --provision-with bootstrap

prov-docker: ## Provisions docker engine
	$(CMD_VAGRANT) provision --provision-with docker

prov-tls: ## Provisions cretificats TLS
	$(CMD_VAGRANT) provision --provision-with cert,tls

prov-compose: ## Provisions docker-compose
	$(CMD_VAGRANT) provision --provision-with compose

prov-test: ## Provisions test scripts
	$(CMD_VAGRANT) provision --provision-with test

# --------------------------------------------------------
##@ Commons Git tasks
# --------------------------------------------------------

# ---------------------

GIT_BRANCH_MAIN := master # Main branch of the project

GIT_LIST_BRANCH_WITHOUT_REMOTE = git branch -vv |  grep -v "*" | grep ": gone]" | cut -c 3- | awk '{print $$1}'
GIT_DEL_BRANCH_WITHOUT_REMOTE = [ -z "$$(${GIT_LIST_BRANCH_WITHOUT_REMOTE})" ] \
									&& echo "No branch to delete." \
									|| $(GIT_LIST_BRANCH_WITHOUT_REMOTE) | xargs git branch -D


SPACE = ${null} ${null}

# ---------------------
git-prune: ## Delete all unused branch (remote ref and local)
	$(eval MODULES = $(shell git submodule | awk '{print $$2}' ) )
	$(eval CURRENT_PATH = $(shell pwd))
	@for mod in $(MODULES) ./; do 				\
		echo "-------------------------"; 		\
		echo "Enter in git repo '$$mod' .."; 	\
		cd $(CURRENT_PATH)/$$mod; 				\
		git fetch --all; 						\
		git remote prune origin; 				\
		$(GIT_DEL_BRANCH_WITHOUT_REMOTE); 		\
	done

# ---------------------
git-master: ## Back to main branch and reset to main branch
	git checkout $(GIT_BRANCH_MAIN)
	git reset --hard origin/$(GIT_BRANCH_MAIN)
	git pull --rebase

# ---------------------
git-config: ## Configure git for working with submodule and define some usefull alias
	git config --global alias.adog "log --all --decorate --oneline --graph"
	git config --global alias.lg1 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
	git config --global alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
	git config --global alias.lg !"git lg2"
	git config --global alias.last !"git lg -15"
	git config --global url."https://github.com/".insteadOf git@github.com:
	git config --global url."https://".insteadOf git://
	git config --global color.diff "auto"
	git config --global color.status "auto"
	git config --global color.branch "auto"
	git config --global diff.submodule "log"
	git config --global pull.rebase true

# --------------------------------------------------------
##@ Commons basics tasks
# --------------------------------------------------------

# source: https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run
bash: ## Open a new bash session
	bash

# source: https://suva.sh/posts/well-documented-makefiles/
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<task>\033[0m\n"} /^[0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
