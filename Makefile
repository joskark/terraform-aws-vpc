ENV ?= default

.PHONY: fmt
fmt:
	@terraform fmt

.PHONY: init
init:
	@TF_DATA_DIR='.terraform_$(ENV)' \
	terraform init

.PHONY: plan
plan:
	@TF_DATA_DIR='.terraform_$(ENV)' \
	terraform plan \
		-lock-timeout=120s \
		-var-file='$(CURDIR)/env/$(ENV).tfvars' \
		-out '$(ENV).plan'

.PHONY: apply
apply:
	@TF_DATA_DIR='.terraform_$(ENV)' \
	terraform apply \
		-lock-timeout=120s \
		'$(ENV).plan'

.PHONY: destroy
destroy:
	@terraform destroy \
		-lock-timeout=120s \
		-var-file='$(CURDIR)/env/$(ENV).tfvars'