package api

import (
	cue_k8s_module "ghcr.io/ciphax/cue_k8s_module"
	"example.com/common"
)

#Module: cue_k8s_module.#Module & {
	name: "api"

	image: common.#Image & {
		repository: _ | *"example.com/api"
		tag:        _ | *"latest"
	}
}
