SHELL=/bin/bash

TERRAFORM=terraform
DIG=dig

PLAN_FILE=terraform.tfplan
STATE_FILE=terraform.tfstate
VAR_FILE=terraform.tfvars

DNS_DOMAIN=tonejito.cf

.PHONY:	all
all:	plan apply test

clean:
	cd modules ; \
	rm -v terraform.tf{plan,state*} || true

plan:
	cd modules ; \
	${TERRAFORM} $@ -no-color -state ${STATE_FILE} -out ${PLAN_FILE}

apply:
	cd modules ; \
	${TERRAFORM} $@ -no-color -state ${STATE_FILE}

destroy:
	cd modules ; \
	${TERRAFORM} $@ -no-color -state ${STATE_FILE}

test:
	for RECORD in "" web www mail smtp imap db ; \
	do \
	  echo "$$ ${DIG} ANY $$RECORD.${DNS_DOMAIN} @8.8.8.8" ; \
	  ${DIG} ANY $$RECORD.${DNS_DOMAIN} @8.8.8.8 ; \
		sleep 2 ; \
	done

# import:
# 	cd modules ; \
# 	${TERRAFORM} $@ aws_route53_zone.dns_zone ${DNS_ZONE_ID}
