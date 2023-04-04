.PHONY: init validate plan apply destroy fmt console
 
init:
	terraform init
	# docker-compose run --rm terraform init
 
validate:
	terraform validate
	# docker-compose run --rm terraform validate
 
plan:
	terraform plan
	# docker-compose run --rm terraform plan
 
apply:
	terraform apply -auto-approve
	# docker-compose run --rm terraform apply -auto-approve
 
destroy:
	terraform destroy -auto-approve
	# docker-compose run --rm terraform destroy -auto-approve
 
fmt:
	terraform fmt -recursive --diff
	# docker-compose run --rm terraform fmt -recursive --diff
 
console:
	terraform console
	# docker-compose run --rm terraform console