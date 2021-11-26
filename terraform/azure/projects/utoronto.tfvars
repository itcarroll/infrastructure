subscription_id    = "ead3521a-d994-4a44-a68d-b16e35642d5b"
resourcegroup_name = "2i2c-utoronto-cluster"

ssh_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQJ4h39UYNi1wybxAH+jCFkNK2aqRcuhDkQSMx0Hak5xkbt3KnT3cOwAgUP1Vt/SjhltSTuxpOHxiAKCRnjwRk60SxKhUNzPHih2nkfYTmBBjmLfdepDPSke/E0VWvTDIEXz/L8vW8aI0QGPXnXyqzEDO9+U1buheBlxB0diFAD3vEp2SqBOw+z7UgrGxXPdP+2b3AV+X6sOtd6uSzpV8Qvdh+QAkd4r7h9JrkFvkrUzNFAGMjlTb0Lz7qAlo4ynjEwzVN2I1i7cVDKgsGz9ZG/8yZfXXx+INr9jYtYogNZ63ajKR/dfjNPovydhuz5zQvQyxpokJNsTqt1CiWEUNj georgiana@georgiana"

global_container_registry_name = "2i2cutorontohubregistry"
global_storage_account_name = "2i2cutorontohubstorage"

location = "canadacentral"

notebook_nodes = {
  "default" : {
    min : 1,
    max : 100,
    vm_size : "Standard_E8s_v3"
  }
}

dask_nodes = {}
