#!/bin/bash

function create_ecs_migration_test() {
    VARIANT=${VARIANT:-"aws-ecs-1"}
    ARCHITECTURE=${ARCHITECTURE:-"x86_64"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${ARCHITECTURE} | tr "_" "-")-$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}-migration.yaml"
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    ECS_TEST_AGENT_IMAGE_URI=${ECS_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ecs-test-agent:v${AGENT_IMAGE_VERSION}"}
    MIGRATION_TEST_AGENT_IMAGE_URI=${MIGRATION_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/migration-test-agent:v${AGENT_IMAGE_VERSION}"}
    ECS_RESOURCE_AGENT_IMAGE_URI=${ECS_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ecs-resource-agent:v${AGENT_IMAGE_VERSION}"}
    EC2_RESOURCE_AGENT_IMAGE_URI=${EC2_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ec2-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    AWS_REGION=${AWS_REGION:-"us-west-2"}
    UPGRADE_VERSION=${UPGRADE_VERSION:-"v1.11.1"}
    STARTING_VERSION=${STARTING_VERSION:-"v1.11.0"}
    METADATA_URL=${METADATA_URL:-"https://updates.bottlerocket.aws/2020-07-07/${VARIANT}/${ARCHITECTURE}"}
    TARGETS_URL=${TARGETS_URL:-"https://updates.bottlerocket.aws/targets"}

    BOTTLEROCKET_AMI_ID=$(aws ssm get-parameter \
    --region ${AWS_REGION} \
    --name "/aws/service/bottlerocket/${VARIANT}/$(echo ${ARCHITECTURE} | sed -e 's/aarch64/arm64/g')/$(echo ${STARTING_VERSION} | tr -d "v")/image_id" \
    --query Parameter.Value --output text)

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/ecs-migration-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_ecs_test() {
    VARIANT=${VARIANT:-"aws-ecs-1"}
    ARCHITECTURE=${ARCHITECTURE:-"x86_64"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${ARCHITECTURE} | tr "_" "-")-$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}.yaml"
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    ECS_RESOURCE_AGENT_IMAGE_URI=${ECS_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ecs-resource-agent:v${AGENT_IMAGE_VERSION}"}
    EC2_RESOURCE_AGENT_IMAGE_URI=${EC2_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ec2-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ECS_TEST_AGENT_IMAGE_URI=${ECS_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ecs-test-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    AWS_REGION=${AWS_REGION:-"us-west-2"}

    BOTTLEROCKET_AMI_ID=$(aws ssm get-parameter \
    --region ${AWS_REGION} \
    --name "/aws/service/bottlerocket/${VARIANT}/${ARCHITECTURE}/latest/image_id" \
    --query Parameter.Value --output text)

    if [ ${CLUSTER_TYPE} = "kind" ]; then
        cli add-secret map  \
         --name "aws-creds" \
         "ACCESS_KEY_ID=${ACCESS_KEY_ID}" \
         "SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}"
    fi

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/ecs-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_ecs_workload_test() {
    VARIANT=${VARIANT:-"aws-ecs-1-nvidia"}
    ARCHITECTURE=${ARCHITECTURE:-"x86_64"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${ARCHITECTURE} | tr "_" "-")-$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}-workload.yaml"
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    ECS_RESOURCE_AGENT_IMAGE_URI=${ECS_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ecs-resource-agent:v${AGENT_IMAGE_VERSION}"}
    EC2_RESOURCE_AGENT_IMAGE_URI=${EC2_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ec2-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ECS_WORKLOAD_AGENT_IMAGE_URI=${ECS_WORKLOAD_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ecs-workload-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    AWS_REGION=${AWS_REGION:-"us-west-2"}
    GPU=${GPU:-"true"}
    INSTANCE_TYPES=$(if [ $GPU = "true" ]; then echo "[\"g4dn.xlarge\"]"; else echo "[\"m5.large\"]"; fi)

    BOTTLEROCKET_AMI_ID=$(aws ssm get-parameter \
    --region ${AWS_REGION} \
    --name "/aws/service/bottlerocket/${VARIANT}/${ARCHITECTURE}/latest/image_id" \
    --query Parameter.Value --output text)

    if [ ${CLUSTER_TYPE} = "kind" ]; then
        cli add-secret map  \
         --name "aws-creds" \
         "ACCESS_KEY_ID=${ACCESS_KEY_ID}" \
         "SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}"
    fi

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/ecs-workload-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_sonobuoy_migration_test() {
    VARIANT=${VARIANT:-"aws-k8s-1.24"}
    ARCHITECTURE=${ARCHITECTURE:-"x86_64"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${ARCHITECTURE} | tr "_" "-")-$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}-migration.yaml"
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    SONOBUOY_TEST_AGENT_IMAGE_URI=${SONOBUOY_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/sonobuoy-test-agent:v${AGENT_IMAGE_VERSION}"}
    MIGRATION_TEST_AGENT_IMAGE_URI=${MIGRATION_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/migration-test-agent:v${AGENT_IMAGE_VERSION}"}
    EKS_RESOURCE_AGENT_IMAGE_URI=${EKS_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/eks-resource-agent:v${AGENT_IMAGE_VERSION}"}
    EC2_RESOURCE_AGENT_IMAGE_URI=${EC2_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ec2-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    AWS_REGION=${AWS_REGION:-"us-west-2"}
    UPGRADE_VERSION=${UPGRADE_VERSION:-"v1.11.1"}
    STARTING_VERSION=${STARTING_VERSION:-"v1.11.0"}
    METADATA_URL=${METADATA_URL:-"https://updates.bottlerocket.aws/2020-07-07/${VARIANT}/${ARCHITECTURE}"}
    TARGETS_URL=${TARGETS_URL:-"https://updates.bottlerocket.aws/targets"}

    BOTTLEROCKET_AMI_ID=$(aws ssm get-parameter \
    --region ${AWS_REGION} \
    --name "/aws/service/bottlerocket/${VARIANT}/${ARCHITECTURE}/$(echo ${STARTING_VERSION} | tr -d "v")/image_id" \
    --query Parameter.Value --output text)

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/sonobuoy-migration-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_sonobuoy_test() {
    VARIANT=${VARIANT:-"aws-k8s-1.24"}
    ARCHITECTURE=${ARCHITECTURE:-"x86_64"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${ARCHITECTURE} | tr "_" "-")-$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}.yaml"
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    SONOBUOY_TEST_AGENT_IMAGE_URI=${SONOBUOY_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/sonobuoy-test-agent:v${AGENT_IMAGE_VERSION}"}
    EKS_RESOURCE_AGENT_IMAGE_URI=${EKS_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/eks-resource-agent:v${AGENT_IMAGE_VERSION}"}
    EC2_RESOURCE_AGENT_IMAGE_URI=${EC2_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ec2-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    AWS_REGION=${AWS_REGION:-"us-west-2"}
    SONOBUOY_MODE=${SONOBUOY_MODE:-"quick"}

    BOTTLEROCKET_AMI_ID=$(aws ssm get-parameter \
    --region ${AWS_REGION} \
    --name "/aws/service/bottlerocket/${VARIANT}/${ARCHITECTURE}/latest/image_id" \
    --query Parameter.Value --output text)

    if [ ${CLUSTER_TYPE} = "kind" ]; then
        cli add-secret map  \
         --name "aws-creds" \
         "ACCESS_KEY_ID=${ACCESS_KEY_ID}" \
         "SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}"
    fi

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/sonobuoy-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_k8s_workload_test() {
    VARIANT=${VARIANT:-"aws-k8s-1.24-nvidia"}
    ARCHITECTURE=${ARCHITECTURE:-"x86_64"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${ARCHITECTURE} | tr "_" "-")-$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}-workload.yaml"
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    K8S_WORKLOAD_AGENT_IMAGE_URI=${K8S_WORKLOAD_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/k8s-workload-agent:v${AGENT_IMAGE_VERSION}"}
    EKS_RESOURCE_AGENT_IMAGE_URI=${EKS_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/eks-resource-agent:v${AGENT_IMAGE_VERSION}"}
    EC2_RESOURCE_AGENT_IMAGE_URI=${EC2_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/ec2-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    AWS_REGION=${AWS_REGION:-"us-west-2"}
    GPU=${GPU:-"true"}
    INSTANCE_TYPES=$(if [ $GPU = "true" ]; then echo "[\"g4dn.xlarge\"]"; else echo "[\"m5.large\"]"; fi)

    BOTTLEROCKET_AMI_ID=$(aws ssm get-parameter \
    --region ${AWS_REGION} \
    --name "/aws/service/bottlerocket/${VARIANT}/${ARCHITECTURE}/latest/image_id" \
    --query Parameter.Value --output text)

    if [ ${CLUSTER_TYPE} = "kind" ]; then
        cli add-secret map  \
         --name "aws-creds" \
         "ACCESS_KEY_ID=${ACCESS_KEY_ID}" \
         "SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}"
    fi

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/k8s-workload-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_vmware_migration_test() {
    VARIANT=${VARIANT:-"vmware-k8s-1.24"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}-migration.yaml"
    K8S_VERSION=${K8S_VERSION:-"1.24"}
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    SONOBUOY_TEST_AGENT_IMAGE_URI=${SONOBUOY_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/sonobuoy-test-agent:v${AGENT_IMAGE_VERSION}"}
    MIGRATION_TEST_AGENT_IMAGE_URI=${MIGRATION_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/migration-test-agent:v${AGENT_IMAGE_VERSION}"}
    VSPHERE_K8S_CLUSTER_RESOURCE_AGENT_IMAGE_URI=${VSPHERE_K8S_CLUSTER_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/vsphere-k8s-cluster-resource-agent:v${AGENT_IMAGE_VERSION}"}
    VSPHERE_VM_RESOURCE_AGENT_IMAGE_URI=${VSPHERE_VM_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/vsphere-vm-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    REGION=${REGION:-"us-west-2"}
    UPGRADE_VERSION=${UPGRADE_VERSION:-"v1.11.1"}
    STARTING_VERSION=${STARTING_VERSION:-"v1.11.0"}
    METADATA_URL=${METADATA_URL:-"https://updates.bottlerocket.aws/2020-07-07/${VARIANT}/x86_64"}
    TARGETS_URL=${TARGETS_URL:-"https://updates.bottlerocket.aws/targets"}
    OVA_NAME=${OVA_NAME:-"bottlerocket-${VARIANT}-x86_64-${STARTING_VERSION}.ova"}
    MGMT_CLUSTER_KUBECONFIG_BASE64=$(cat ${MGMT_CLUSTER_KUBECONFIG_PATH} | base64)

    cli add-secret map  \
    --name "vsphere-creds" \
    "username=${GOVC_USERNAME}" \
    "password=${GOVC_PASSWORD}"

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/vmware-migration-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

function create_vmware_sonobuoy_test() {
    VARIANT=${VARIANT:-"vmware-k8s-1.24"}
    CLUSTER_NAME=${CLUSTER_NAME:-"$(echo ${VARIANT} | tr -d ".")"}
    OUTPUT_FILE="output/${CLUSTER_NAME}.yaml"
    K8S_VERSION=${K8S_VERSION:-"1.24"}
    AGENT_IMAGE_VERSION=${AGENT_IMAGE_VERSION:-$(cli --version | sed -e "s/^.* //g")}
    SONOBUOY_TEST_AGENT_IMAGE_URI=${SONOBUOY_TEST_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/sonobuoy-test-agent:v${AGENT_IMAGE_VERSION}"}
    VSPHERE_K8S_CLUSTER_RESOURCE_AGENT_IMAGE_URI=${VSPHERE_K8S_CLUSTER_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/vsphere-k8s-cluster-resource-agent:v${AGENT_IMAGE_VERSION}"}
    VSPHERE_VM_RESOURCE_AGENT_IMAGE_URI=${VSPHERE_VM_RESOURCE_AGENT_IMAGE_URI:-"public.ecr.aws/bottlerocket-test-system/vsphere-vm-resource-agent:v${AGENT_IMAGE_VERSION}"}
    ASSUME_ROLE=${ASSUME_ROLE:-"~"}
    REGION=${REGION:-"us-west-2"}
    SONOBUOY_MODE=${SONOBUOY_MODE:-"quick"}
    VERSION=${VERSION:-"v1.11.1"}
    METADATA_URL=${METADATA_URL:-"https://updates.bottlerocket.aws/2020-07-07/${VARIANT}/x86_64"}
    TARGETS_URL=${TARGETS_URL:-"https://updates.bottlerocket.aws/targets"}
    OVA_NAME=${OVA_NAME:-"bottlerocket-${VARIANT}-x86_64-${VERSION}.ova"}
    MGMT_CLUSTER_KUBECONFIG_BASE64=$(cat $MGMT-CLUSTER-KUBECONFIG-PATH | base64)

    cli add-secret map  \
    --name "vsphere-creds" \
    "username=${GOVC_USERNAME}" \
    "password=${GOVC_PASSWORD}"

    eval "cat > ${OUTPUT_FILE} << EOF
$(< eks/vmware-sonobuoy-test.yaml)
EOF
" 2> /dev/null

    echo "${OUTPUT_FILE}"
}

TEST_TYPE=$1
CLUSTER_TYPE=$2

case $TEST_TYPE in
    "ecs-migration")
        create_ecs_migration_test
        ;;
    
    "ecs")
        create_ecs_test
        ;;
    
    "ecs-workload")
        create_ecs_workload_test
        ;;
    
    "sonobuoy-migration")
        create_sonobuoy_migration_test
        ;;
    
    "sonobuoy")
        create_sonobuoy_test
        ;;
    
    "k8s-workload")
        create_k8s_workload_test
        ;;
    
    "vmware-migration")
        create_vmware_migration_test
        ;;
    
    "vmware-sonobuoy")
        create_vmware_sonobuoy_test
        ;;
    
    *)
        echo "Invalid test type supplied"
        exit 1
        ;;
esac
