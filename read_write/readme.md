
# Manual fail-over

With this instruction, you will be able to create a fully-functional 3 node(1 primary, 2 secondary) replica to perform a high availability in the Kubernetes environment with read write routing.

Clone repository:

```git clone https://github.com/khaninejad/mssql-ha.git ```

``` cd read_write ```

Create a secret key for SA user:

``` kubectl create secret generic mssql --from-literal=SA_PASSWORD="&ddGd@bd12354vA" ```

Primary replica persistence volume claim:

``` kubectl apply -f 1_persitance_volume_claim_primary.yml ```

Note: we are using [rook-ceph-block](https://github.com/rook/rook/blob/master/Documentation/ceph-block.md) as persistence storage, yours may be different. please check out the link for [Kubernetes Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/)


Deploy primary replica:

``` kubectl apply -f 2_mssql_deploy_primary_primary.yml ```

Secondary replicas persistence volume claim:

``` kubectl apply -f 3_persitance_volume_claim_secondary.yml ```

Deploy secondary replicas:

``` kubectl apply -f 4_mssql_deploy_secondray.yml ```

Deploy services:

``` kubectl apply -f 5_service.yml ```

Connect to the primary node using SSMS or other SQL  management tools

Execute [this](https://github.com/khaninejad/mssql-ha/blob/main/read_write/6_sql_primary.sql) file in the primary node. after this step, availability rules will be created along with database and routing.

Copy primary node SSL certificate to secondary nodes:

``` chmod +x 7_copy_ssl.sh  ```

``` bash 7_copy_ssl.sh  ```

Execute SQL  commands in each of the secondary nodes using [this](https://github.com/khaninejad/mssql-ha/blob/main/read_write/8_sql_secondary.sql) file

That's it. you're ready to test.

Screenshot:

![ha ](screenshot.PNG?raw=true)