#![cfg(feature = "integ")]
mod data;
use assert_cmd::Command;
use selftest::Cluster;
use tokio::time::Duration;

/// The amount of time we will wait for the controller to run, a test-agent to run, etc. before we
/// consider the selftest a failure. This can be a very long time on resource constrained or
/// machines running a VM for docker.
const POD_TIMEOUT: Duration = Duration::from_secs(300);

#[tokio::test]
async fn test_install() {
    let cluster_name = "install-test";
    let cluster = Cluster::new(cluster_name).unwrap();
    cluster.load_image_to_cluster("controller:integ").unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "install",
        "--controller-uri",
        "controller:integ",
    ]);
    cmd.assert().success();
    cluster.wait_for_controller(POD_TIMEOUT).await.unwrap();
}

#[tokio::test]
async fn test_run_file() {
    let cluster_name = "run-file-test";
    let cluster = Cluster::new(cluster_name).unwrap();
    cluster.load_image_to_cluster("controller:integ").unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "install",
        "--controller-uri",
        "controller:integ",
    ]);
    cmd.assert().success();
    cluster
        .load_image_to_cluster("example-test-agent:integ")
        .unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "run",
        "file",
        data::hello_example_path().to_str().unwrap(),
    ]);
    cmd.assert().success();

    cluster.wait_for_controller(POD_TIMEOUT).await.unwrap();

    cluster
        .wait_for_test_pod("hello-bones", POD_TIMEOUT)
        .await
        .unwrap();
}

#[tokio::test]
async fn test_status() {
    let cluster_name = "status-test";
    let cluster = Cluster::new(cluster_name).unwrap();
    cluster.load_image_to_cluster("controller:integ").unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "install",
        "--controller-uri",
        "controller:integ",
    ]);
    cmd.assert().success();
    cluster
        .load_image_to_cluster("example-test-agent:integ")
        .unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "run",
        "file",
        data::hello_example_path().to_str().unwrap(),
    ]);
    cmd.assert().success();

    cluster.wait_for_controller(POD_TIMEOUT).await.unwrap();

    cluster
        .wait_for_test_pod("hello-bones", POD_TIMEOUT)
        .await
        .unwrap();

    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "status",
        "--wait",
    ]);
    cmd.assert().success();
}

#[tokio::test]
async fn test_set() {
    let cluster_name = "set-test";
    let cluster = Cluster::new(cluster_name).unwrap();
    cluster.load_image_to_cluster("controller:integ").unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "install",
        "--controller-uri",
        "controller:integ",
    ]);
    cmd.assert().success();
    cluster
        .load_image_to_cluster("example-test-agent:integ")
        .unwrap();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "run",
        "file",
        data::hello_example_path().to_str().unwrap(),
    ]);
    cmd.assert().success();

    cluster.wait_for_controller(POD_TIMEOUT).await.unwrap();

    cluster
        .wait_for_test_pod("hello-bones", POD_TIMEOUT)
        .await
        .unwrap();

    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "set",
        "hello-bones",
        "--keep-running",
        "false",
    ]);
    cmd.assert().success();
    let mut cmd = Command::cargo_bin("testsys").unwrap();
    cmd.args(&[
        "--kubeconfig",
        cluster.kubeconfig().to_str().unwrap(),
        "status",
        "--wait",
    ]);
    cmd.assert().success();
}
