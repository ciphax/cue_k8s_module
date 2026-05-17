package example

import (
	cue_k8s_module "ghcr.io/ciphax/cue_k8s_module"
)

command: cue_k8s_module.#Commands & {
	#module: #Module
}
