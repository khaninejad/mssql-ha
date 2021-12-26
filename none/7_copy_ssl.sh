for a in $(kubectl get pod -o jsonpath="{.items[*].metadata.name}"  -l type=primary); do \
  echo -e "\nPod ${a}"; \
  kubectl cp ${a}:var/opt/mssql/data/ag_certificate.cert /root/ag_certificate.cert 
  kubectl cp ${a}:var/opt/mssql/data/ag_certificate.key /root/ag_certificate.key 
done
for a in $(kubectl get pods -o jsonpath="{.items[*].metadata.name}" -l type=secondary); do \
  echo -e "\nPod ${a}"; \
  kubectl cp /root/ag_certificate.cert  ${a}:/var/opt/mssql/data/ag_certificate.cert 
  kubectl cp /root/ag_certificate.key ${a}:/var/opt/mssql/data/ag_certificate.key  
done