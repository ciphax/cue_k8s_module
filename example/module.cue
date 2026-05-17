package example

import (
	cue_k8s_module "ghcr.io/ciphax/cue_k8s_module"
	"example.com/api"
)

#Module: cue_k8s_module.#Module & {
	name: "example"

	modules: {
		"api": api.#Module
	}

	helm: nginx: {
		chart:   "oci://registry-1.docker.io/bitnamicharts/nginx"
		version: "23.0.3"
		values: {
			fullnameOverride: "\(name)-nginx"
		}
	}
}
