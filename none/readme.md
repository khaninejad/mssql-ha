
# Manual fail-over

With this instruction you will be able to create a fully-functional 4 node(1 primary, 3 secondary) replica to perform a high availability in Kubernetes environment

Clone repository:

```git clone https://github.com/khaninejad/mssql-ha.git ```

``` cd none ```

Create a secret key for SA user:

``` kubectl create secret generic mssql --from-literal=SA_PASSWORD="&ddGd@bd12354vA" ```

Primary replica persistence volume claim:

``` kubectl apply -f 1_persitance_volume_claim_primary.yml ```

note: we are using [rook-ceph-block](https://github.com/rook/rook/blob/master/Documentation/ceph-block.md) as persistence storage, yours maybe different. please checkout the link for [Kubernetes Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/)

