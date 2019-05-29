SHELL=/bin/bash

TERRAFORM=terraform

PLAN_FILE=terraform.tfplan
STATE_FILE=terraform.tfstate
VAR_FILE=terraform.tfvars

.PHONY:	all
all:	plan apply

clean:
	cd modules ; \
	rm -v terraform.tf{plan,state*} || true

plan:
	cd modules ; \
	${TERRAFORM} $@ -state ${STATE_FILE} -out ${PLAN_FILE}

apply:
	cd modules ; \
	${TERRAFORM} $@ -state ${STATE_FILE}

destroy:
	cd modules ; \
	${TERRAFORM} $@ -state ${STATE_FILE}

# import:
# 	cd modules ; \
# 	${TERRAFORM} $@ aws_route53_zone.dns_zone ${DNS_ZONE_ID}
