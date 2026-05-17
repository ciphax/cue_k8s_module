module: "ghcr.io/ciphax/cue_k8s_module@v1"
language: version: "v0.16.1"
source: kind:      "git"
deps: {
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.7.0"
		default: true
	}
}
