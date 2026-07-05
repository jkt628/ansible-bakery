.PHONY: default
default:
	echo >&2 pick a target
	exit 1

.PHONY: FORCE
*.yml: FORCE
	ansible-playbook $(if ${LIMIT},--limit ${LIMIT},) ${ANSIBLE_FLAGS} $@

tasks/%.yml: FORCE
	ansible-playbook $(if ${LIMIT},--limit ${LIMIT},) ${ANSIBLE_FLAGS} -e task=$@ task.yml
