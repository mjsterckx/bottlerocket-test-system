.PHONY: create-ecs-migration-test create-ecs-test create-ecs-workload-test create-sonobuoy-migration-test \
	create-sonobuoy-test create-k8s-workload-test create-vmware-migration-test create-vmware-sonobuoy-test

CLUSTER_TYPE ?= "kind"

create-ecs-migration-test:
	echo $(shell scripts/create_sample_file.sh ecs-migration eks)

create-ecs-test:
	echo $(shell scripts/create_sample_file.sh ecs ${CLUSTER_TYPE})

create-ecs-workload-test:
	echo $(shell scripts/create_sample_file.sh ecs-workload ${CLUSTER_TYPE})

create-sonobuoy-migration-test:
	echo $(shell scripts/create_sample_file.sh sonobuoy-migration eks)

create-sonobuoy-test:
	echo $(shell scripts/create_sample_file.sh sonobuoy ${CLUSTER_TYPE})

create-k8s-workload-test:
	echo $(shell scripts/create_sample_file.sh k8s-workload ${CLUSTER_TYPE})

create-vmware-migration-test:
	echo $(shell scripts/create_sample_file.sh vmware-migration eks)

create-vmware-sonobuoy-test:
	echo $(shell scripts/create_sample_file.sh vmware-sonobuoy ${CLUSTER_TYPE})
